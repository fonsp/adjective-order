### A Pluto.jl notebook ###
# v0.14.0

using Markdown
using InteractiveUtils

# ╔═╡ 53c045a8-7032-11eb-1e32-979e2d2b7846
begin
	#temp environment
    import Pkg
    Pkg.activate(mktempdir())
    Pkg.add([
        Pkg.PackageSpec(name="DataFrames", version="0.22"),
        Pkg.PackageSpec(name="CSV", version="0.8"),
        Pkg.PackageSpec(name="Plots", version="1"),
    ])
	
	#import packages
    using DataFrames, CSV, Statistics, Plots
	
	theme(:wong, legend=:outerright) #plot theme
end

# ╔═╡ 75ed3aeb-ca7c-4db8-82e9-7fdd7b394b97
md"""
## Import
"""

# ╔═╡ fb243fdd-76ce-4ea2-b38c-d3450e9b01b1
all_results =  CSV.read(
	"results/results_filtered.csv", DataFrame,
)

# ╔═╡ 7ade9d08-b89d-477c-8ede-c3cdbf1d4cd3
md"""
## Acceptability judgements

### Formatting
"""

# ╔═╡ 9d94d22d-6ebf-4f26-a8ed-321ebb81c972
item_results = let
	df = all_results[
		(all_results.item_type .== "test") .| (all_results.item_type .== "filler"), 
		:]
	
	df.response = parse.(Int64, df.response)
	
	df
end ;

# ╔═╡ f38b95f7-b8c5-4b14-b305-d0f5b4639d2c
md"""
### Distribution of responses 

**All responses**
"""

# ╔═╡ adbb424d-cab8-4457-9862-063d96b32f28
md"""
**Only test items**
"""

# ╔═╡ 1d618621-118b-4bd6-b7ca-a017fbb3cb63
test_results = item_results[item_results.item_type .== "test", :] ;

# ╔═╡ e5383671-e932-43f6-92fa-3e446b56b687
md"**Filler items: acceptable**"

# ╔═╡ 8f63f0e9-dbcc-414e-90e0-ed815383d113
filler_results = item_results[item_results.item_type .== "filler", :] ;

# ╔═╡ ec46d379-6620-4e76-89aa-20ea217f9ce5
md"**Filler items: unacceptable**"

# ╔═╡ 0e4c77e7-b910-4ed9-9dab-d1ae6d2fd475
md"**Filler items: questionable**"

# ╔═╡ 771607e6-dbbc-4883-9bad-cdd68e0d99a7
md"""
### Response time
"""

# ╔═╡ f8b4c2f0-3ed9-4225-a40d-62008ec51754
histogram(
	item_results[:, "time"],
	label = nothing
)

# ╔═╡ 860e9c66-4268-4d09-b7ce-d3b8eca84537
md"""
### Order preference


**All test data**

Compare the acceptability of *target first* ("big expensive") and *target second* ("expensive big"). 

Also compare between the bimodal condition (where the target adjective is expected to be less subjective) and the unimodal condition.
"""

# ╔═╡ 6083e4df-0a27-476f-83d8-7e9c6b21d351
md"""
**Scalar-scalar combinations**

Only compare "long expensive", "big expensive", "long cheap", "big cheap"
"""

# ╔═╡ 57d977cc-d93f-42d6-bacb-c6f06c0b4c68
scalar_data = test_results[test_results.adj_secondary_type .== "scalar", :] ;

# ╔═╡ 6dd07dbb-bd31-46c1-a5d0-f561c4ef1f87
md"""
**Absolute-scalar combinations**

Compare "big refurbished", "long leather"
"""

# ╔═╡ 404b5626-c603-4996-97df-f5b08b24930b
absolute_data = test_results[test_results.adj_secondary_type .== "absolute", :] ;

# ╔═╡ 586961f3-127b-424d-8599-9cb765054850
md"**Results per adjective combination**"

# ╔═╡ 215219a4-47a6-4c5f-b1e0-0c8c270ff3f3
md"""
## General functions
"""

# ╔═╡ 2e9afc98-7e13-45e5-ba23-d0daa4d8afb2
scale = 1:5

# ╔═╡ 7b2998f7-dc66-49b4-9d0d-71a7b357df38
function response_counts(responses)
	map(scale) do score
		count(responses .== score)
	end
end

# ╔═╡ 43e082be-6457-4125-ab46-4c50d7a38bc2
function plot_response_counts(responses)
	counts = response_counts(responses)
	p = bar(scale, counts, 
		label = nothing, xlabel = "response", ylabel = "frequency",
	)	
	return p
end

# ╔═╡ 934eccc1-e6e0-4183-b6bf-ff150f9acdf4
plot_response_counts(item_results.response)

# ╔═╡ f6acabc7-4c3d-4173-a6e4-e2ba65c3e3dd
plot_response_counts(test_results[:, "response"])

# ╔═╡ 5b05f3d8-c9d7-4a75-a7ac-32e34199cc88
plot_response_counts(
		filler_results[filler_results.filler_acceptability .== "acceptable", "response"]
	)

# ╔═╡ c1535d4c-9fa3-4194-8e23-756a7b7bb4b3
plot_response_counts(
	filler_results[filler_results.filler_acceptability .== "unacceptable", 
		"response"]
)

# ╔═╡ ec9479e2-0819-4edb-8579-c0fac793b9de
plot_response_counts(
	filler_results[filler_results.filler_acceptability .== "questionable", "response"]
)

# ╔═╡ 3c5c9818-33af-4cbe-921c-010f78a059bb
function discrete_violin!(plot::Plots.Plot, x::AbstractArray, y::AbstractArray;
		position = :center,
		kwargs...
	)
	
	x_set = sort(unique(x))
	#y_set = sort(unique(y))
	y_set = scale
	for (i, x_value) in enumerate(x_set)
		hits = x .== x_value
		y_values = y[hits]

		counts = map(y_set) do value
			count(y_values .== value)
		end

		normalised_counts = counts ./ (1.5 * sum(counts))
		
		for (j, value) in enumerate(normalised_counts)
			x1, x2 = if position == :center
				(i - 0.5value, i + 0.5value)
			elseif position == :right
				(i, i + value)
			else
				(i - value, i)
			end
			y1 = j + 0.5
			y2 = j - 0.5
			primary = i ==1 && j == 1
			
			rectangle = Shape([(x1, y1), (x1, y2), (x2, y2), (x2, y1)])
			plot!(plot, rectangle, primary = primary; kwargs...)
			
		end
		
	end
	
	plot!(plot,
		xticks = (1:length(x_set), x_set),
		yticks = (1:length(y_set), y_set)
	)
end

# ╔═╡ f99af668-ddae-414f-ad51-17c58f2d4b84
let
	combinations = (sort ∘ unique ∘ zip)(test_results.adj_target, test_results.adj_secondary)
	
	plots = map(combinations) do (target, secondary)
		data = test_results[test_results.adj_target .== target, :]
		data = data[data.adj_secondary .== secondary, :]
		
		bimodal_data = data[data.condition .== "bimodal", :]
		unimodal_data = data[data.condition .== "unimodal", :]
	
	
		p = plot(
			title = target * " - " * secondary,
			legend = nothing,
		)
		discrete_violin!(p, 
			bimodal_data.order, bimodal_data.response,
			position = :left,
			label = "bimodal",
		)
		discrete_violin!(p, 
			unimodal_data.order, unimodal_data.response,
			position = :right,
			label = "unimodal",
		)
		p
	end
	
	plot(plots..., layout = (4,2), size = (600, 700))
end

# ╔═╡ 5538434d-b77e-4d77-9ca1-328ab1f423d3
function plot_discrete_violin(data)
	bimodal_data = data[data.condition .== "bimodal", :]
	unimodal_data = data[data.condition .== "unimodal", :]
	
	
	p = plot(
		xlabel = "position of target adjective",
		ylabel = "rating",
	)
	discrete_violin!(p, 
		bimodal_data.order, bimodal_data.response,
		position = :left,
		label = "bimodal",
	)
	discrete_violin!(p, 
		unimodal_data.order, unimodal_data.response,
		position = :right,
		label = "unimodal",
	)
	p
end

# ╔═╡ 89d741fd-04a3-4aa2-9105-ef7da99a8f29
plot_discrete_violin(test_results)

# ╔═╡ 2e8c9de6-e28b-4625-8bcc-94709528f466
plot_discrete_violin(scalar_data)

# ╔═╡ b2a7f59c-fe1a-4419-a2c9-9b6d57e0d029
plot_discrete_violin(absolute_data)

# ╔═╡ 7968aaf4-c8a3-4163-bf7a-0d8935c27229
function aggregate_responses(data)
	positions =  ["first", "second"]
	order_data = map(positions) do position
		data[data.order .== position, :]
	end
	
	bimodal_means = map(order_data) do data
		condition_data = data[data.condition .== "bimodal", :]
		mean(condition_data.response)
	end
	
	unimodal_means = map(order_data) do data
		condition_data = data[data.condition .== "unimodal", :]
		mean(condition_data.response)
	end
	
	DataFrame(
		target_position = ["first", "second"],
		mean_judgement_bimodal = bimodal_means,
		mean_judgement_unimodal = unimodal_means,
	)
end

# ╔═╡ f6c3b498-ad94-4b0d-9e0d-07a4e8ca4f49
function plot_aggregated_responses(data)
	aggregated_responses = aggregate_responses(data)
	
	p = plot(
		xlabel = "position target adjective",
		ylabel = "mean acceptability",
		ylims = (3,5)
	)
	plot!(p, 
		aggregated_responses.target_position,
		aggregated_responses.mean_judgement_bimodal,
		label = "bimodal",
		lw = 3
	)
	plot!(p, 
		aggregated_responses.target_position,
		aggregated_responses.mean_judgement_unimodal,
		label = "unimodal",
		lw = 3
	)
end

# ╔═╡ 38a7e895-aba0-4988-9ae9-b50571808a22
plot_aggregated_responses(test_results)

# ╔═╡ a602dc1f-5acb-4abb-a9b0-6937709e99c8
plot_aggregated_responses(scalar_data)

# ╔═╡ 05803aad-d182-4be8-9fe3-54aaa7ae919d
plot_aggregated_responses(absolute_data)

# ╔═╡ Cell order:
# ╟─75ed3aeb-ca7c-4db8-82e9-7fdd7b394b97
# ╠═53c045a8-7032-11eb-1e32-979e2d2b7846
# ╠═fb243fdd-76ce-4ea2-b38c-d3450e9b01b1
# ╟─7ade9d08-b89d-477c-8ede-c3cdbf1d4cd3
# ╠═9d94d22d-6ebf-4f26-a8ed-321ebb81c972
# ╟─f38b95f7-b8c5-4b14-b305-d0f5b4639d2c
# ╠═934eccc1-e6e0-4183-b6bf-ff150f9acdf4
# ╟─adbb424d-cab8-4457-9862-063d96b32f28
# ╠═1d618621-118b-4bd6-b7ca-a017fbb3cb63
# ╟─f6acabc7-4c3d-4173-a6e4-e2ba65c3e3dd
# ╟─e5383671-e932-43f6-92fa-3e446b56b687
# ╠═8f63f0e9-dbcc-414e-90e0-ed815383d113
# ╟─5b05f3d8-c9d7-4a75-a7ac-32e34199cc88
# ╟─ec46d379-6620-4e76-89aa-20ea217f9ce5
# ╟─c1535d4c-9fa3-4194-8e23-756a7b7bb4b3
# ╟─0e4c77e7-b910-4ed9-9dab-d1ae6d2fd475
# ╟─ec9479e2-0819-4edb-8579-c0fac793b9de
# ╟─771607e6-dbbc-4883-9bad-cdd68e0d99a7
# ╟─f8b4c2f0-3ed9-4225-a40d-62008ec51754
# ╟─860e9c66-4268-4d09-b7ce-d3b8eca84537
# ╟─89d741fd-04a3-4aa2-9105-ef7da99a8f29
# ╟─38a7e895-aba0-4988-9ae9-b50571808a22
# ╟─6083e4df-0a27-476f-83d8-7e9c6b21d351
# ╠═57d977cc-d93f-42d6-bacb-c6f06c0b4c68
# ╠═2e8c9de6-e28b-4625-8bcc-94709528f466
# ╟─a602dc1f-5acb-4abb-a9b0-6937709e99c8
# ╟─6dd07dbb-bd31-46c1-a5d0-f561c4ef1f87
# ╠═404b5626-c603-4996-97df-f5b08b24930b
# ╟─b2a7f59c-fe1a-4419-a2c9-9b6d57e0d029
# ╟─05803aad-d182-4be8-9fe3-54aaa7ae919d
# ╟─586961f3-127b-424d-8599-9cb765054850
# ╟─f99af668-ddae-414f-ad51-17c58f2d4b84
# ╟─215219a4-47a6-4c5f-b1e0-0c8c270ff3f3
# ╠═2e9afc98-7e13-45e5-ba23-d0daa4d8afb2
# ╠═7b2998f7-dc66-49b4-9d0d-71a7b357df38
# ╠═43e082be-6457-4125-ab46-4c50d7a38bc2
# ╠═5538434d-b77e-4d77-9ca1-328ab1f423d3
# ╠═3c5c9818-33af-4cbe-921c-010f78a059bb
# ╠═7968aaf4-c8a3-4163-bf7a-0d8935c27229
# ╠═f6c3b498-ad94-4b0d-9e0d-07a4e8ca4f49
