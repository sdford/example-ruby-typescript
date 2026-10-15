import type { Measurement } from "../types";

const LABELS: Record<string, string> = {
  roof_area: "Roof area",
  siding_area: "Siding area",
  window_count: "Windows",
  gutter_length: "Gutters",
};

export default function MeasurementTable({ measurements }: { measurements: Measurement[] }) {
  return (
    <table>
      <tbody>
        {measurements.map((m) => (
          <tr key={m.kind}>
            <th scope="row">{LABELS[m.kind] ?? m.kind}</th>
            <td>
              {m.value.toLocaleString()} {m.unit}
            </td>
          </tr>
        ))}
      </tbody>
    </table>
  );
}
