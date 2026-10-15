import { Link } from "react-router-dom";
import type { Project } from "../types";

export default function ProjectList({
  projects,
}: {
  projects: Project[];
}) {
  if (projects.length === 0) {
    return <p>No projects yet.</p>;
  }

  return (
    <ul>
      {projects.map((p) => (
        <li key={p.id}>
          <Link to={`/projects/${p.id}`}>{p.name}</Link>{" "}
          <span>{p.address}</span>{" "}
          <em>{p.status}</em>
        </li>
      ))}
    </ul>
  );
}
