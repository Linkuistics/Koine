/**
 * The client-owned half of search. The contract says only that "query entry,
 * suggestions and typed-query fallback remain client-owned; Koine does not
 * construct searches or contact Google". Everything here is therefore this
 * client's own decision, and each decision is in the findings record.
 */

export const DEFAULT_ENGINE_TEMPLATE = 'https://www.google.com/search?q=%s';

/** How long the suggestion source gets, connection to last byte of body. */
export const SUGGESTION_TIMEOUT_MS = 2_000;

/** A suggestion answer larger than this is not read further. */
const SUGGESTION_BODY_LIMIT = 1024 * 1024;

const PLACEHOLDER = '%s';

/**
 * Percent-encodes the UTF-8 bytes of `text`: every byte outside the RFC 3986
 * unreserved set (ALPHA, DIGIT, `-`, `.`, `_`, `~`) becomes `%` and two upper-case
 * hex digits; a space is `%20`, never `+`.
 */
export function percentEncodeUtf8(text: string): string {
  let out = '';
  for (const byte of Buffer.from(text, 'utf8')) {
    const unreserved =
      (byte >= 0x30 && byte <= 0x39) ||
      (byte >= 0x41 && byte <= 0x5a) ||
      (byte >= 0x61 && byte <= 0x7a) ||
      byte === 0x2d ||
      byte === 0x2e ||
      byte === 0x5f ||
      byte === 0x7e;
    out += unreserved ? String.fromCharCode(byte) : `%${byte.toString(16).toUpperCase().padStart(2, '0')}`;
  }
  return out;
}

/** A template is usable when it carries exactly one `%s`. Returns the text around it, or a reason. */
export function splitTemplate(template: string): { readonly before: string; readonly after: string } | string {
  const first = template.indexOf(PLACEHOLDER);
  if (first < 0) return 'it has no %s';
  if (template.indexOf(PLACEHOLDER, first + 1) >= 0) return 'it has more than one %s';
  return { before: template.slice(0, first), after: template.slice(first + PLACEHOLDER.length) };
}

/** The template with its one `%s` replaced by the encoded query. Slicing, not `replace`, so `$` in anything is literal. */
export function fillTemplate(template: string, query: string): string {
  const parts = splitTemplate(template);
  if (typeof parts === 'string') throw new Error(`template ${JSON.stringify(template)} is unusable: ${parts}`);
  return `${parts.before}${percentEncodeUtf8(query)}${parts.after}`;
}

export interface SuggestionReport {
  readonly attempted: boolean;
  readonly outcome: 'not-attempted' | 'answered' | 'failed';
  readonly detail: string;
}

/**
 * Asks the suggestion source with one plain GET and never throws. `answered` means
 * HTTP 2xx and a body that reads as the common suggestions answer, a JSON array whose
 * second element is a list of strings (`["query", ["a", "b"]]`); anything else —
 * a refused connection, a timeout, a redirect, a non-2xx status, a body that is not
 * that — is `failed`, with the reason. Redirects are refused so that this client
 * contacts the suggestion source and nothing it points to.
 */
export async function askSuggestions(suggestionsUrl: string | undefined, query: string): Promise<SuggestionReport> {
  if (suggestionsUrl === undefined) {
    return { attempted: false, outcome: 'not-attempted', detail: 'no --suggestions-url given' };
  }
  let url: string;
  try {
    url = fillTemplate(suggestionsUrl, query);
  } catch (cause) {
    return { attempted: false, outcome: 'failed', detail: cause instanceof Error ? cause.message : String(cause) };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), SUGGESTION_TIMEOUT_MS);
  try {
    const response = await fetch(url, { method: 'GET', redirect: 'error', signal: controller.signal });
    if (response.status < 200 || response.status > 299) {
      await response.body?.cancel().catch(() => undefined);
      return { attempted: true, outcome: 'failed', detail: `HTTP ${response.status}` };
    }
    const text = await readBounded(response, SUGGESTION_BODY_LIMIT);
    if (text === null) return { attempted: true, outcome: 'failed', detail: 'answer exceeds the size this client reads' };
    let parsed: unknown;
    try {
      parsed = JSON.parse(text);
    } catch {
      return { attempted: true, outcome: 'failed', detail: 'HTTP 200 but the body is not JSON' };
    }
    if (!Array.isArray(parsed) || !Array.isArray(parsed[1]) || !parsed[1].every((s) => typeof s === 'string')) {
      return { attempted: true, outcome: 'failed', detail: 'JSON, but not [query, [suggestion, ...]]' };
    }
    return { attempted: true, outcome: 'answered', detail: `HTTP ${response.status}, ${parsed[1].length} suggestion(s)` };
  } catch (cause) {
    if (controller.signal.aborted) {
      return { attempted: true, outcome: 'failed', detail: `no complete answer within ${SUGGESTION_TIMEOUT_MS} ms` };
    }
    return { attempted: true, outcome: 'failed', detail: describe(cause) };
  } finally {
    clearTimeout(timer);
  }
}

async function readBounded(response: Response, limit: number): Promise<string | null> {
  if (response.body === null) return '';
  const reader = response.body.getReader();
  const chunks: Uint8Array[] = [];
  let total = 0;
  for (;;) {
    const { done, value } = await reader.read();
    if (done) break;
    total += value.byteLength;
    if (total > limit) {
      await reader.cancel().catch(() => undefined);
      return null;
    }
    chunks.push(value);
  }
  return Buffer.concat(chunks).toString('utf8');
}

function describe(cause: unknown): string {
  let current: unknown = cause;
  for (let depth = 0; depth < 5 && current !== null && typeof current === 'object'; depth += 1) {
    const code = (current as { code?: unknown }).code;
    if (typeof code === 'string') return code;
    current = (current as { cause?: unknown }).cause;
  }
  return cause instanceof Error ? cause.message : String(cause);
}
