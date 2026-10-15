org = Organization.find_or_create_by!(name: "Ridgeline Roofing")

[
  ["Dana Admin", "admin@ridgeline.test", :admin],
  ["Eli Editor", "editor@ridgeline.test", :editor],
  ["Vic Viewer", "viewer@ridgeline.test", :viewer]
].each do |name, email, role|
  user = User.find_or_create_by!(email: email) do |u|
    u.name = name
    u.password = "password123"
  end
  Membership.find_or_create_by!(user: user, organization: org) { |m| m.role = role }
end

admin = User.find_by!(email: "admin@ridgeline.test")
project = org.projects.find_or_create_by!(name: "Kim residence", address: "412 Alder St, Portland, OR") do |p|
  p.created_by = admin
  p.status = :ready
  p.notes = "Homeowner wants a quote for full reroof and gutters."
end
project.measurements.find_or_create_by!(kind: "roof_area") { |m| m.value = 2310; m.unit = "sqft" }
project.measurements.find_or_create_by!(kind: "gutter_length") { |m| m.value = 164; m.unit = "ft" }
