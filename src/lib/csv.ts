/** Quote untrusted text for a human-readable CSV, neutralizing formula-leading cells.
 * This does not mutate the stored value or numeric amount fields. Spreadsheet re-save
 * may remove protective quoting/prefixes; exported text is not a typed workbook.
 */
export function csvTextCell(value: string): string {
  const trimmed = value.trimStart();
  const unsafe =
    /^[=+\-@＝＋－＠]/.test(trimmed) ||
    ['\t', '\r', '\n', '\0'].some((prefix) => value.startsWith(prefix)) ||
    trimmed.startsWith('\0');
  const safe = unsafe ? "'" + value : value;
  return '"' + safe.replace(/"/g, '""') + '"';
}
