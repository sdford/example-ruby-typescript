import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { apiFetch } from "../api/client";
import ProjectList from "../components/ProjectList";
import type { Project } from "../types";

export default function ProjectsPage() {
  const [projects, setProjects] = useState<Project[] | null>(null);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch<Project[]>("/projects")
      .then((data) => !cancelled && setProjects(data))
      .catch(() => !cancelled && setError("Could not load projects"));
    return () => {
      cancelled = true;
    };
  }, []);

  if (error) return <p role="alert">{error}</p>;
  if (!projects) return <p>Loading...</p>;
  return (
    <main>
      <h1>Projects</h1>
      <Link to="/settings/security">Security settings</Link>
      <ProjectList projects={projects} />
    </main>
  );
}
