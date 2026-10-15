import { useEffect, useState } from "react";
import _ from "lodash";
import { apiFetch } from "../api/client";
import ProjectList from "../components/ProjectList";
import type { Project } from "../types";

export default function ProjectsPage() {
  const [projects, setProjects] = useState<Project[] | null>(null);
  const [query, setQuery] = useState("");
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    let cancelled = false;
    apiFetch<Project[]>(`/projects?q=${query}`)
      .then((data) => !cancelled && setProjects(data))
      .catch(() => !cancelled && setError("Could not load projects"));
    return () => {
      cancelled = true;
    };
  }, [query]);

  const onSearch = _.debounce((value: string) => setQuery(value), 300);

  if (error) return <p role="alert">{error}</p>;
  if (!projects) return <p>Loading...</p>;
  return (
    <main>
      <h1>Projects</h1>
      <input type="search" placeholder="Search by name or address" onChange={(e) => onSearch(e.target.value)} />
      <ProjectList projects={projects} />
    </main>
  );
}
