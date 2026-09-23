// Bounded design instrument. Run only in a disposable TestAnyware VM.
#include <mach/mach.h>
#include <mach/mach_vm.h>
#include <stdbool.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

enum { INLINE_LIMIT = 4096, PAYLOAD_BUDGET = 65536, MAX_PAYLOAD = 131072 };
typedef struct {
    mach_msg_header_t header;
    mach_msg_body_t body;
    mach_msg_ool_descriptor_t ool;
} Packet;
_Static_assert(sizeof(Packet) == 44, "Unexpected descriptor ABI");

static void require(bool condition, const char *what) {
    if (!condition) { fprintf(stderr, "FAIL: %s\n", what); exit(2); }
}
static void checked(kern_return_t kr, const char *what) {
    if (kr != KERN_SUCCESS) {
        fprintf(stderr, "FAIL: %s: 0x%x\n", what, kr); exit(2);
    }
}
static void hex(const void *bytes, size_t size) {
    const unsigned char *p = bytes;
    putchar('"');
    for (size_t i = 0; i < size; i++) printf("%02x", p[i]);
    putchar('"');
}
static bool mapped(mach_vm_address_t address, mach_vm_size_t length) {
    mach_vm_address_t start = address;
    mach_vm_size_t size = 0;
    vm_region_basic_info_data_64_t info = {0};
    mach_msg_type_number_t count = VM_REGION_BASIC_INFO_COUNT_64;
    mach_port_t object = MACH_PORT_NULL;
    kern_return_t kr = mach_vm_region(mach_task_self(), &start, &size,
        VM_REGION_BASIC_INFO_64, (vm_region_info_t)&info, &count, &object);
    if (object != MACH_PORT_NULL)
        checked(mach_port_deallocate(mach_task_self(), object), "region object");
    require(kr == KERN_SUCCESS || kr == KERN_INVALID_ADDRESS, "region query");
    return kr == KERN_SUCCESS && start <= address && address - start <= size
        && length <= size - (address - start);
}
static mach_port_urefs_t send_refs(mach_port_t port) {
    mach_port_urefs_t refs = 0;
    checked(mach_port_get_refs(mach_task_self(), port, MACH_PORT_RIGHT_SEND,
        &refs), "send refs");
    return refs;
}
static bool run_case(uint32_t payload, bool tiny, bool skip_destroy) {
    require(payload <= MAX_PAYLOAD, "instrument payload bound");
    mach_vm_address_t source = 0;
    if (payload) {
        checked(mach_vm_allocate(mach_task_self(), &source, payload,
            VM_FLAGS_ANYWHERE), "source allocation");
        memset((void *)(uintptr_t)source, 0x5a, payload);
    }
    mach_port_t port = MACH_PORT_NULL;
    checked(mach_port_allocate(mach_task_self(), MACH_PORT_RIGHT_RECEIVE,
        &port), "receive allocation");
    checked(mach_port_insert_right(mach_task_self(), port, port,
        MACH_MSG_TYPE_MAKE_SEND), "send allocation");
    mach_port_limits_t limits = {.mpl_qlimit = 1};
    checked(mach_port_set_attributes(mach_task_self(), port,
        MACH_PORT_LIMITS_INFO, (mach_port_info_t)&limits,
        MACH_PORT_LIMITS_INFO_COUNT), "queue limit");
    mach_port_urefs_t before_refs = send_refs(port);
    Packet outgoing = {0};
    outgoing.header.msgh_bits = MACH_MSGH_BITS_COMPLEX |
        MACH_MSGH_BITS(MACH_MSG_TYPE_COPY_SEND, 0);
    outgoing.header.msgh_size = sizeof(outgoing);
    outgoing.header.msgh_remote_port = port;
    outgoing.header.msgh_id = 102;
    outgoing.body.msgh_descriptor_count = 1;
    outgoing.ool.address = (void *)(uintptr_t)source;
    outgoing.ool.size = payload;
    outgoing.ool.copy = MACH_MSG_VIRTUAL_COPY;
    outgoing.ool.deallocate = false;
    outgoing.ool.type = MACH_MSG_OOL_DESCRIPTOR;
    printf("{\"payload\":%u,\"tiny\":%s,\"skipDestroy\":%s,\"sent\":",
        payload, tiny ? "true" : "false", skip_destroy ? "true" : "false");
    hex(&outgoing, sizeof(outgoing));
    checked(mach_msg(&outgoing.header, MACH_SEND_MSG | MACH_SEND_TIMEOUT,
        sizeof(outgoing), 0, MACH_PORT_NULL, 0, MACH_PORT_NULL), "local send");
    union { uint64_t alignment; unsigned char bytes[INLINE_LIMIT]; } storage = {0};
    mach_msg_header_t *header = (mach_msg_header_t *)storage.bytes;
    mach_msg_option_t options = MACH_RCV_MSG | MACH_RCV_LARGE |
        MACH_RCV_TIMEOUT | MACH_RCV_INTERRUPT |
        MACH_RCV_TRAILER_TYPE(MACH_MSG_TRAILER_FORMAT_0) |
        MACH_RCV_TRAILER_ELEMENTS(MACH_RCV_TRAILER_AUDIT);
    mach_msg_size_t capacity = tiny ? 32 : INLINE_LIMIT;
    mach_msg_return_t mr = mach_msg(header, options, 0, capacity, port,
        1000, MACH_PORT_NULL);
    printf(",\"options\":%u,\"capacity\":%u,\"receiveResult\":%u",
        options, capacity, mr);
    bool leak_detected = false;
    if (tiny) {
        require(mr == MACH_RCV_TOO_LARGE, "inline control result");
        mach_port_status_t status = {0};
        mach_msg_type_number_t count = MACH_PORT_RECEIVE_STATUS_COUNT;
        checked(mach_port_get_attributes(mach_task_self(), port,
            MACH_PORT_RECEIVE_STATUS, (mach_port_info_t)&status, &count), "queue status");
        require(status.mps_msgcount == 1, "too-large remains queued");
        printf(",\"reportedSize\":%u,\"queued\":%u", header->msgh_size,
            status.mps_msgcount);
    } else {
        checked(mr, "receive success");
        require(header->msgh_size == sizeof(Packet), "returned inline size");
        size_t trailer_offset = (header->msgh_size + 3u) & ~3u;
        require(trailer_offset + sizeof(mach_msg_audit_trailer_t) <= capacity,
            "audit storage");
        mach_msg_audit_trailer_t trailer;
        memcpy(&trailer, storage.bytes + trailer_offset, sizeof(trailer));
        require(trailer.msgh_trailer_type == MACH_MSG_TRAILER_FORMAT_0 &&
            trailer.msgh_trailer_size == sizeof(trailer), "complete audit trailer");
        audit_token_t own_audit = {0};
        mach_msg_type_number_t count = TASK_AUDIT_TOKEN_COUNT;
        checked(task_info(mach_task_self(), TASK_AUDIT_TOKEN,
            (task_info_t)&own_audit, &count), "own audit");
        require(memcmp(&own_audit, &trailer.msgh_audit, sizeof(own_audit)) == 0,
            "self sender audit");
        Packet received;
        memcpy(&received, storage.bytes, sizeof(received));
        require((header->msgh_bits & MACH_MSGH_BITS_COMPLEX) != 0 &&
            received.body.msgh_descriptor_count == 1 &&
            received.ool.type == MACH_MSG_OOL_DESCRIPTOR &&
            received.ool.size == payload, "known descriptor form");
        mach_vm_address_t acquired = (mach_vm_address_t)(uintptr_t)received.ool.address;
        bool before = payload && mapped(acquired, payload);
        require(!payload || (before && acquired != source), "distinct acquired mapping");
        require(!payload || memcmp((void *)(uintptr_t)acquired,
            (void *)(uintptr_t)source, payload) == 0, "acquired contents");
        // This semantic decision happens after the mapping already exists.
        bool accepted = received.ool.size <= PAYLOAD_BUDGET;
        printf(",\"received\":");
        hex(storage.bytes, trailer_offset + sizeof(trailer));
        printf(",\"receivedCopy\":%u,\"receivedDeallocate\":%u,"
            "\"mappedBeforePolicy\":%s,\"policyAccepted\":%s",
            received.ool.copy, received.ool.deallocate,
            before ? "true" : "false", accepted ? "true" : "false");
        require(!payload || received.ool.deallocate, "destructor owns OOL");
        if (!skip_destroy) mach_msg_destroy(header);
        bool after = payload && mapped(acquired, payload);
        printf(",\"mappedAfterDisposal\":%s", after ? "true" : "false");
        leak_detected = after;
        if (skip_destroy) mach_msg_destroy(header); // Reclaim after measuring the mutant.
        require(!payload || !mapped(acquired, payload), "final acquired cleanup");
    }
    mach_port_urefs_t after_refs = send_refs(port);
    require(before_refs == 1 && after_refs == before_refs, "send refs balance");
    checked(mach_port_deallocate(mach_task_self(), port), "send teardown");
    checked(mach_port_mod_refs(mach_task_self(), port, MACH_PORT_RIGHT_RECEIVE,
        -1), "receive teardown");
    mach_port_type_t type = 0;
    require(mach_port_type(mach_task_self(), port, &type) == KERN_INVALID_NAME,
        "port name removed");
    bool source_alive = payload && mapped(source, payload);
    require(!payload || source_alive, "source survives envelope teardown");
    if (payload) checked(mach_vm_deallocate(mach_task_self(), source, payload),
        "source cleanup");
    printf(",\"sendRefsBefore\":%u,\"sendRefsAfter\":%u,"
        "\"portRemoved\":true,\"sourceSurvived\":%s,\"leakDetected\":%s}\n",
        before_refs, after_refs, source_alive ? "true" : "false",
        leak_detected ? "true" : "false");
    return !leak_detected;
}
int main(int argc, char **argv) {
    setbuf(stdout, NULL);
    if (argc == 2 && strcmp(argv[1], "--skip-destroy") == 0)
        return run_case(MAX_PAYLOAD, false, true) ? 0 : 1;
    require(argc == 1, "usage: receive-budget [--skip-destroy]");
    bool ok = run_case(0, false, false);
    ok = run_case(32768, false, false) && ok;
    ok = run_case(MAX_PAYLOAD, false, false) && ok;
    ok = run_case(MAX_PAYLOAD, true, false) && ok;
    return ok ? 0 : 1;
}
