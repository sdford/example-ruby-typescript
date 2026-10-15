class ProjectSerializer
  def initialize(project, include_measurements: false)
    @project = project
    @include_measurements = include_measurements
  end

  def as_json(*)
    data = {
      id: @project.id,
      name: @project.name,
      address: @project.address,
      notes: @project.notes,
      status: @project.status,
      updated_at: @project.updated_at.iso8601
    }
    data[:measurements] = measurements if @include_measurements
    data
  end

  private

  def measurements
    @project.measurements.map do |m|
      { kind: m.kind, value: m.value.to_f, unit: m.unit }
    end
  end
end
