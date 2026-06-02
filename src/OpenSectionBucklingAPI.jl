module OpenSectionBucklingAPI

using JSON, StructTypes, OpenSectionBuckling, CUFSMModalGeometry, SectionProperties

struct CalculateOpenSectionBuckling
  E::Float64
  ν::Float64
  t::Float64
  coordinates::NamedTuple{(:X, :Y),Tuple{Vector{Float64},Vector{Float64}}}
  centerline_radius::Float64
  loads::NamedTuple{(:P, :Mxx, :Mzz, :M11, :M22),NTuple{5,Float64}}
  load_type::String
  flat_mesh_size_goal::Float64
  corner_mesh_size_goal::Float64
  mode_shape_element_discretization::Int
end

struct OpenSectionBucklingResult
  local_buckling_label::String
  distortional_buckling_label::String
  Lcrℓ::Float64
  Lcrd::Float64
  Rcrℓ::Float64
  Rcrd::Float64
  local_buckling_mode_shape::Any
  distortional_buckling_mode_shape::Any
  section_properties::Any
end

StructTypes.StructType(::Type{CalculateOpenSectionBuckling}) = StructTypes.Struct()
StructTypes.StructType(::Type{OpenSectionBucklingResult}) = StructTypes.Struct()


function parse_request(json_string::String)::CalculateOpenSectionBuckling
  d = JSON.parse(json_string)
  coords = d["coordinates"]
  loads = d["loads"]
  return CalculateOpenSectionBuckling(
    d["E"],
    d["ν"],
    d["t"],
    (X=Float64.(coords["X"]), Y=Float64.(coords["Y"])),
    d["centerline_radius"],
    (P=loads["P"], Mxx=loads["Mxx"], Mzz=loads["Mzz"], M11=loads["M11"], M22=loads["M22"]),
    d["load_type"],
    d["flat_mesh_size_goal"],
    d["corner_mesh_size_goal"],
    d["mode_shape_element_discretization"]
  )
end


function calculate(request::CalculateOpenSectionBuckling)::OpenSectionBucklingResult

  E = request.E
  ν = request.ν
  t = request.t

  #straight line for everything right now
  X = request.coordinates.X
  Y = request.coordinates.Y

  centerline_radius = request.centerline_radius

  load_type = request.load_type
  loads = request.loads

  element_discretization = request.mode_shape_element_discretization

  flat_mesh_size_goal = request.flat_mesh_size_goal
  corner_mesh_size_goal = request.corner_mesh_size_goal

  t_all = fill(t, length(X) - 1)
  section_properties = SectionProperties.open_thin_walled(X, Y, t_all)

  straight, rounded = OpenSectionBuckling.discretize_general_coordinates(X, Y, flat_mesh_size_goal, corner_mesh_size_goal, centerline_radius, t)

  coordinates = (straight=straight, rounded=rounded)

  material = (E=E, ν=ν)

  all_results = []

  mode_type = ["D"]
  model = OpenSectionBuckling.properties(coordinates, material, loads, t, mode_type)

  label = load_type * "_crd"
  Lcr = model.curve[1][1]
  Rcr = model.curve[1][2]

  results = (label=label, Lcr=Lcr, Rcr=Rcr, model=model)

  push!(all_results, results)


  mode_type = ["L"]
  model = OpenSectionBuckling.properties(coordinates, material, loads, t, mode_type)

  label = load_type * "_crℓ"
  Lcr = model.curve[1][1]
  Rcr = model.curve[1][2]

  results = (label=label, Lcr=Lcr, Rcr=Rcr, model=model)

  push!(all_results, results)

  #get mode shapes

  model = all_results[1].model
  eig = 1
  deformation_scale = [0.5, 0.5]
  t_elements = model.elem[:, 4]
  distortional_buckling_mode_shape = CUFSMModalGeometry.get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)

  model = all_results[2].model
  eig = 1
  deformation_scale = [0.5, 0.5]
  t_elements = model.elem[:, 4]
  local_buckling_mode_shape = CUFSMModalGeometry.get_mode_shape_coordinates(model, eig, t_elements, element_discretization, deformation_scale)

  return OpenSectionBucklingResult(
    all_results[2].label,
    all_results[1].label,
    all_results[2].Lcr,
    all_results[1].Lcr,
    all_results[2].Rcr,
    all_results[1].Rcr,
    local_buckling_mode_shape,
    distortional_buckling_mode_shape,
    section_properties
  )

end

export CalculateOpenSectionBuckling, OpenSectionBucklingResult, parse_request, calculate

end # module OpenSectionBucklingAPI
