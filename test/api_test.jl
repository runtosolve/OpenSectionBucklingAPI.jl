using OpenSectionBucklingAPI, JSON, OpenSectionBuckling


# X = [0.0, 1.0, 2.0, 3.0, 4.0]
# Y = [0.0, 2.0, 6.0, 8.0, 3.0]

# coordinates = (X=X, Y=Y)

# E = 29500.0
# ν = 0.30 
# t = 0.102 

# P = 1.0
# Mxx = 0.0
# Mzz = 0.0
# M11 = 0.0
# M22 = 0.0

# loads = (P=P, Mxx=Mxx, Mzz=Mzz, M11=M11, M22=M22)


# flat_mesh_size_goal = 0.5
# corner_mesh_size_goal = π/6
# centerline_radius = 2 * t 

# mode_shape_element_discretization = 2

# load_type = "P"

# inputs = OpenSectionBucklingAPI.Inputs(E, ν, t, coordinates, centerline_radius, loads, load_type, flat_mesh_size_goal, corner_mesh_size_goal, mode_shape_element_discretization)


# JSON.json(joinpath(@__DIR__, "inputs.json"), inputs)



inputs_path = joinpath(@__DIR__, "inputs.json")

serial_path = joinpath(@__DIR__, "outputs.json")


OpenSectionBucklingAPI.perform_calculation(inputs_path, serial_path)






