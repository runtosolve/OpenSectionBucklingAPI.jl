module OpenSectionBucklingAPI

using JSON, OpenSectionBuckling, CUFSMModalGeometry, SectionProperties

struct Inputs

    E
    ν

    t 
    coordinates
    centerline_radius

    loads 
    load_type

    flat_mesh_size_goal
    corner_mesh_size_goal

    mode_shape_element_discretization

end


struct Outputs 

    local_buckling_label
    distortional_buckling_label
    Lcrℓ
    Lcrd
    Rcrℓ
    Rcrd 
    local_buckling_mode_shape 
    distortional_buckling_mode_shape
    section_properties

end


function perform_calculation(inputs_path, serial_path)

    inputs = open(inputs_path) do f; JSON.parse(f); end

    E = inputs.E 
    ν = inputs.ν
    t = inputs.t 

    #straight line for everything right now 
    X = inputs.coordinates.X 
    Y = inputs.coordinates.Y 

    centerline_radius = inputs.centerline_radius 

    load_type = inputs.load_type
    loads = inputs.loads 

    element_discretization = inputs.mode_shape_element_discretization


    flat_mesh_size_goal = inputs.flat_mesh_size_goal
    corner_mesh_size_goal = inputs.corner_mesh_size_goal


    t_all = fill(t, length(X)-1)
    section_properties = SectionProperties.open_thin_walled(X, Y, t_all)


    straight, rounded = OpenSectionBuckling.discretize_general_coordinates(X, Y, flat_mesh_size_goal, corner_mesh_size_goal, centerline_radius, t)

    coordinates = (straight=straight, rounded=rounded)

    material = (E=E, ν=ν)

  
    all_results = []

    mode_type = ["D"]
    model = OpenSectionBuckling.properties(coordinates, material, loads, t, mode_type)

    label = load_type * "_crd" 
    Lcr =   model.curve[1][1]
    Rcr =   model.curve[1][2]

    results = (label=label, Lcr=Lcr, Rcr=Rcr, model=model)

    push!(all_results, results)



    mode_type = ["L"]
    model = OpenSectionBuckling.properties(coordinates, material, loads, t, mode_type)

    label = load_type * "_crℓ" 
    Lcr =   model.curve[1][1]
    Rcr =   model.curve[1][2]

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
    

    outputs = Outputs(all_results[2].label, all_results[1].label, all_results[2].Lcr, all_results[1].Lcr, all_results[2].Rcr, all_results[1].Rcr, local_buckling_mode_shape, distortional_buckling_mode_shape, section_properties)

    open(serial_path, "w") do f
        JSON.json(f, outputs)
        println(f)
    end

end


end # module OpenSectionBucklingAPI
