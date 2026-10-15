import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import { apiFetch } from "../api/client";
import MeasurementTable from "../components/MeasurementTable";
import type { Project } from "../types";

export default function ProjectPage() {
  const { id } = useParams();
  const [project, setProject] = useState<Project | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch<Project>(`/projects/${id}`)
      .then((data) => !cancelled && setProject(data))
      .catch(() => !cancelled && setError("Could not load project"));
    return () => {
      cancelled = true;
    };
  }, [id]);

  if (error) return <p role="alert">{error}</p>;
  if (!project) return <p>Loading...</p>;
  return (
    <main>
      <h1>{project.name}</h1>
      <p>{project.address}</p>
      {project.notes && <p>{project.notes}</p>}
      <MeasurementTable measurements={project.measurements ?? []} />
    </main>
  );
}
