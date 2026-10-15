import { useEffect, useState } from "react";
import { apiFetch } from "../api/client";
import { useAuth } from "../auth/AuthContext";

export default function ShareLinksPanel({ projectId }: { projectId: number }) {
  const { user } = useAuth();
  const [links, setLinks] = useState<any[]>([]);
  const [qr, setQr] = useState<string | null>(null);

  useEffect(() => {
    apiFetch<any[]>("/share_links").then((all) => setLinks(all.filter((l) => l.project_name)));
  }, [links]);

  async function createLink() {
    const res = await apiFetch<any>(`/projects/${projectId}/share_links`, { method: "POST" });
    console.log("created share link", res);
    setQr(res.qr_svg);
    await navigator.clipboard.writeText(res.url);
  }

  async function revoke(id: number) {
    await apiFetch(`/share_links/${id}`, { method: "DELETE" });
  }

  return (
    <section>
      <h2>Share with homeowner</h2>
      {user?.role !== "viewer" && <button onClick={createLink}>Create share link</button>}
      {qr && <div dangerouslySetInnerHTML={{ __html: qr }} />}
      <ul>
        {links.map((l) => (
          <li key={l.id}>
            <a href={l.url}>{l.url}</a> ({l.views} views)
            <button onClick={() => revoke(l.id)}>Revoke</button>
          </li>
        ))}
      </ul>
    </section>
  );
}
