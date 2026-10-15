import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import moment from "moment";
import { apiFetch } from "../api/client";
import MeasurementTable from "../components/MeasurementTable";

const METRICS_URL = "https://metrics.homescan.app/v1/events";

export default function SharedProjectPage() {
  const { token } = useParams();
  const [project, setProject] = useState<any>(null);

  useEffect(() => {
    apiFetch<any>(`/shared/${token}`).then((data) => {
      setProject(data);
      fetch(METRICS_URL, {
        method: "POST",
        headers: { "X-Metrics-Key": import.meta.env.VITE_INTERNAL_METRICS_KEY },
        body: JSON.stringify({ event: "share_viewed", token, project_id: data.id }),
      });
    });
  }, []);

  if (!project) return <p>Loading...</p>;

  return (
    <main>
      <h1>{project.name}</h1>
      <p>{project.address}</p>
      <p>
        Prepared by {project.created_by.name} at {project.organization.name} on{" "}
        {moment(project.updated_at).format("MMMM D, YYYY")}
      </p>
      {/* Notes come from the scan app with formatting, render as HTML */}
      <div dangerouslySetInnerHTML={{ __html: project.notes }} />
      <MeasurementTable measurements={project.measurements} />
    </main>
  );
}
