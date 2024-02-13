include("fitting.jl")

model_bursty_mult = CellPopulationModel(bursty_rn, DivisionRateBounded(γτ₋Sm*f_2,1.0,bursty_rn), BinomialKernel(0.5))
#opt₊Sm_bursty_mult_hill = optimise_parameters_hill(model_bursty_mult; 
#    ps=ps_bursty₊Sm, 
#    pbounds=[(0.0,100), (0.0, 1000)],
#    likelihood=likelihood_joint, 
#    data=df_div₊Sm, 
#    inf=-60000, 
#    trn=working_trn,
#    max_evals=100)


analyticals_bursty_mult₊Sm = run_analytical_single(model_bursty_mult, experiment_setup(model_parameters=fit_param, trn=working_trn); solver_opts...)
division_dist!(analyticals_bursty_mult₊Sm)

fig = Figure(resolution=(1000, 800))
xs = collect(1:working_trn)
ts = 0.0:0.1:150.0
colors = ColorSchemes.Egypt.colors
transp = 0.6

ax_birth = Axis(fig[1,1], xlabel="Protein counts", ylabel="Probability density", title="Birth distribution")
ax_div = Axis(fig[1,2], xlabel="Protein counts", ylabel="Probability density", title="Division distribution")
ax_interdiv = Axis(fig[2,1], xlabel="Time", ylabel="Probability density", title="Interdivision time distribution")
ax_sel = Axis(fig[2,2], xlabel="Protein counts x", ylabel="Selection f(x)")

xs = collect(1:working_trn)
birth_hist₋Sm = normalize(fit(Histogram, df_birth₋Sm[:, :Column2], 1:100); mode=:pdf)
stairs!(ax_birth, collect(midpoints(birth_hist₋Sm.edges[1])), birth_hist₋Sm.weights; color=colors[1], step=:center)
barplot!(ax_birth, collect(midpoints(birth_hist₋Sm.edges[1])), birth_hist₋Sm.weights; 
    color=(colors[1], transp), strokecolor=(colors[1], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_birth, xs, analyticals_bursty₋Sm.results[:birth_dist]; color=colors[1], linewidth=3.0, label="No treatment")

birth_hist₊Sm = normalize(fit(Histogram, df_birth₊Sm[:, :Column2], 1:100); mode=:pdf)
stairs!(ax_birth, collect(midpoints(birth_hist₊Sm.edges[1])), birth_hist₊Sm.weights; color=colors[2], step=:center)
barplot!(ax_birth, collect(midpoints(birth_hist₊Sm.edges[1])), birth_hist₊Sm.weights; 
    color=(colors[2], transp), strokecolor=(colors[2], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_birth, xs, analyticals_bursty_mult₊Sm.results[:birth_dist]; color=colors[2], linewidth=3.0, label="Treatment")
xlims!(ax_birth, (25, 100))

div_hist₋Sm = normalize(fit(Histogram, df_div₋Sm[:, :Column3], 1:200); mode=:pdf)
stairs!(ax_div, collect(midpoints(div_hist₋Sm.edges[1])), div_hist₋Sm.weights; color=colors[1], step=:center)
barplot!(ax_div, collect(midpoints(div_hist₋Sm.edges[1])), div_hist₋Sm.weights; 
    color=(colors[1], transp), strokecolor=(colors[1], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_div, xs, analyticals_bursty₋Sm.results[:division_dist]; color=colors[1], linewidth=3.0)

div_hist₊Sm = normalize(fit(Histogram, df_div₊Sm[:, :Column3], 1:200); mode=:pdf)
stairs!(ax_div, collect(midpoints(div_hist₊Sm.edges[1])), div_hist₊Sm.weights; color=colors[2], step=:center)
barplot!(ax_div, collect(midpoints(div_hist₊Sm.edges[1])), div_hist₊Sm.weights; 
    color=(colors[2], transp), strokecolor=(colors[2], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_div, xs, analyticals_bursty_mult₊Sm.results[:division_dist]; color=colors[2], linewidth=3.0)
xlims!(ax_div, (50, 200))

ts = 0.0:0.1:150.0
div_dist₋Sm = division_time_dist(analyticals_bursty₋Sm)
div_dist₊Sm = division_time_dist(analyticals_bursty_mult₊Sm)

interdiv_hist₋Sm = normalize(fit(Histogram, interdiv_times₋Sm .* 5, 1:5:maximum(interdiv_times₋Sm .* 5)); mode=:pdf)
stairs!(ax_interdiv, collect(midpoints(interdiv_hist₋Sm.edges[1])), interdiv_hist₋Sm.weights; color=colors[1], step=:center)
barplot!(ax_interdiv, collect(midpoints(interdiv_hist₋Sm.edges[1])), interdiv_hist₋Sm.weights; 
    color=(colors[1], transp), strokecolor=(colors[1], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_interdiv, ts, div_dist₋Sm.(ts); color=colors[1], linewidth=3.0)
interdiv_hist₊Sm = normalize(fit(Histogram, interdiv_times₊Sm .* 5, 1:5:maximum(interdiv_times₊Sm .* 5)); mode=:pdf)
stairs!(ax_interdiv, collect(midpoints(interdiv_hist₊Sm.edges[1])), interdiv_hist₊Sm.weights; color=colors[2], step=:center)
barplot!(ax_interdiv, collect(midpoints(interdiv_hist₊Sm.edges[1])), interdiv_hist₊Sm.weights; 
    color=(colors[2], transp), strokecolor=(colors[2], transp), strokewidth=0.0, gap=0.0, dodge_gap=0.0)
lines!(ax_interdiv, ts, div_dist₊Sm.(ts); color=colors[2], linewidth=3.0)
xlims!(ax_interdiv, (25, 150))

lines!(ax_sel, xs, fx_.(xs; ps=fit_param[2:end], n=2), linewidth=3.0)
xlims!(ax_sel, (0, 200))

Legend(fig[3, 1:2], ax_birth, orientation = :horizontal, tellwidth = false, tellheight = true, framevisible=false)
mkpath("$(plotsdir())/Wakamoto")
#save("$(plotsdir())/Wakamoto/fitting_mcmc_$strain.pdf", fig)

#birth_div = collect.(collect(zip(analyticals_bursty₋Sm.results[:birth_dist], analyticals_bursty₋Sm.results[:division_dist])))
#birth_div = reduce(hcat, vec.(birth_div))'
#CSV.write("$(datadir())/exp_pro/Wakamoto/F3NW-Sm/birth_div_theory_noSm.csv",  
#        Tables.table(birth_div), writeheader=false)
#CSV.write("$(datadir())/exp_pro/Wakamoto/F3NW-Sm/pdf_interdiv_noSm.csv",
#          Tables.table(div_dist₋Sm.(ts)), writeheader=false)


birth_div₊Sm = collect.(collect(zip(analyticals_bursty_mult₊Sm.results[:birth_dist], analyticals_bursty_mult₊Sm.results[:division_dist])))
birth_div₊Sm = reduce(hcat, vec.(birth_div₊Sm))'
CSV.write("$(datadir())/exp_pro/Wakamoto/F3NW+Sm/birth_div_theory_yesSm_reaction_rates_changed.csv",  
        Tables.table(birth_div₊Sm), writeheader=false)
CSV.write("$(datadir())/exp_pro/Wakamoto/F3NW+Sm/pdf_interdiv_yesSm_reaction_rates_changed.csv",
          Tables.table(div_dist₊Sm.(ts)), writeheader=false)