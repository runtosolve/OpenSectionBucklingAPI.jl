using Test
using OpenSectionBucklingAPI

const JSON_PATH = joinpath(@__DIR__, "inputs.json")

@testset "parse_request" begin
    json_string = read(JSON_PATH, String)
    result = parse_request(json_string)

    @test result isa Request

    @test result.E == 29500.0
    @test result.ν == 0.3
    @test result.t == 0.102
    @test result.centerline_radius == 0.204
    @test result.load_type == "P"
    @test result.flat_mesh_size_goal == 0.5
    @test result.mode_shape_element_discretization == 2

    @test result.coordinates.X == [0.0, 1.0, 2.0, 3.0, 4.0]
    @test result.coordinates.Y == [0.0, 2.0, 6.0, 8.0, 3.0]

    @test result.loads.P == 1.0
    @test result.loads.Mxx == 0.0
end

@testset "calculate" begin
    json_string = read(JSON_PATH, String)
    request = parse_request(json_string)
    result = calculate(request)

    @test result isa Response

    @test !isempty(result.local_buckling_label)
    @test occursin("crℓ", result.local_buckling_label)

    @test !isempty(result.distortional_buckling_label)
    @test occursin("crd", result.distortional_buckling_label)

    @test result.Lcrℓ > 0
    @test result.Lcrd > 0

    @test result.Rcrℓ > 0
    @test result.Rcrd > 0
end
