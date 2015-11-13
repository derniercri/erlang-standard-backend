%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This source code and work is provided and developed by Gene I. Sher & DXNN Research Group WWW.DXNNResearch.COM
%
%The original release of this source code and the DXNN MK2 system was introduced and explained in my book: Handbook of Neuroevolution Through Erlang. Springer 2012, print ISBN: 978-1-4614-4462-6 ebook ISBN: 978-1-4614-4463-6. 
%
%Copyright (C) 2009 by Gene Sher, DXNN Research Group CorticalComputer@gmail.com
%
%   Licensed under the Apache License, Version 2.0 (the "License");
%   you may not use this file except in compliance with the License.
%   You may obtain a copy of the License at
%
%     http://www.apache.org/licenses/LICENSE-2.0
%
%   Unless required by applicable law or agreed to in writing, software
%   distributed under the License is distributed on an "AS IS" BASIS,
%   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
%   See the License for the specific language governing permissions and
%   limitations under the License.
%%%%%%%%%%%%%%%%%%%% Deus Ex Neural Network :: DXNN %%%%%%%%%%%%%%%%%%%%
%TODO:
%1. Add Hall-of-fame algorithm
%2. Allow for phylogenetic tree to be built
%3. Add Nueral-circuits
%4. Connect to flatland
%5. Update benchmark reporting?
-define(BEHAVIORAL_TRACE,false).
-define(INTERACTIVE_SELECTION,false).
-record(sensor,{id,name,type,cx_id,scape,vl,fanout_ids=[],generation,format,parameters,gt_parameters,phys_rep,vis_rep,pre_f,post_f}).
-record(actuator,{id,name,type,cx_id,scape,vl,fanin_ids=[],generation,format,parameters,gt_parameters,phys_rep,vis_rep,pre_f,post_f}).
-record(neuron, {id, generation, cx_id, pre_processor, signal_integrator, af, post_processor, pf, aggr_f, input_idps=[], input_idps_modulation=[], output_ids=[], ro_ids=[]}).
-record(cortex, {id, agent_id, neuron_ids=[], sensor_ids=[], actuator_ids=[]}).
-record(substrate, {id, agent_id, densities, linkform, plasticity=none, cpp_ids=[],cep_ids=[]}).
-record(agent,{id, encoding_type, generation, population_id, specie_id, cx_id, fingerprint, constraint, evo_hist=[], fitness=0, innovation_factor=0, pattern=[], tuning_selection_f, annealing_parameter, tuning_duration_f, perturbation_range, mutation_operators, tot_topological_mutations_f, heredity_type, substrate_id, offspring_ids=[], parent_ids=[], champion_flag=[false], evolvability=0, brittleness=0, robustness=0, evolutionary_capacitance=0, behavioral_trace,fs=1,main_fitness}).
-record(champion,{hof_fingerprint,id,fitness,validation_fitness,test_fitness,main_fitness,tot_n,evolvability,robustness,brittleness,generation,behavioral_differences,fs}).
-record(specie,{id, population_id, fingerprint, constraint, all_agent_ids=[],agent_ids=[], dead_pool=[], champion_ids=[], fitness, innovation_factor={0,0},stats=[], seed_agent_ids=[], hof_distinguishers=[tot_n], specie_distinguishers=[tot_n], hall_of_fame=[]}).%TODO: Add specie_size
-record(trace,{stats=[],tot_evaluations=0,step_size=500}).
-record(population,{id, polis_id, specie_ids=[], morphologies=[], innovation_factor, evo_alg_f, fitness_postprocessor_f, selection_f, trace=#trace{}, seed_agent_ids=[],seed_specie_ids=[]}).
-record(stat,{morphology,specie_id,avg_neurons,std_neurons,avg_fitness,std_fitness,max_fitness,min_fitness,validation_fitness,test_fitness,avg_diversity,evaluations,time_stamp}).
-record(topology_summary,{type,tot_neurons,tot_n_ils,tot_n_ols,tot_n_ros,af_distribution}).
-record(signature,{generalized_Pattern,generalized_EvoHist,generalized_Sensors,generalized_Actuators,topology_summary}).

%type [standard,dae,ae], noise [float()], lp_decay [float()], lp_min[float()], lp_max [float()], memory [list()], memory_size {max_size::int(),counter::int()}
-record(circuit,{
	id,
	i,%input_idps::[{id(),vl}]
	ovl,%int()
	ivl,
	training,%{TrainingType::bp|rbm|ga,TrainingLength::int()|{validation_goal,float()}}
	output,%[float()]
	parameters,%list()
	dynamics,%static|dynamic
%	layers_spec,%[{af(),IVL::int(),static|dynamic,Receptive_Field::int(),Step::int()}]
	layers,%[#neurode|#layer|#circuit]
	type=standard,%standard|dae|ae|sdae|sae|{pooling,max|avg|min}
	noise,%float()|undefined
	noise_type=zero_mask,%zero_mask|gaussian|saltnpepper|undefined
	lp_decay=0.999999,%float()
	lp_min=0.0000001,%float()
	lp_max=0.1,%float()
%	receptive_field=full,%full|int()
	memory=[],%[list()]
	memory_size={0,100000},%{int(),int()}
	validation,%[float()]
	testing,%[float()]
	receptive_field=full,%full|int()
	step=0,%int()
	block_size=100,%int()
	err_acc=0,
	backprop_tuning=off,
	training_length=1000
}).
-record(layer,{
	id,%Z::float()
	type,
	noise,
%	type=standard,%{convolutional,VL}|{pooling,max|avg|min}|fully_connected|standard
	neurode_type=tanh,%tanh|sin|cos|rbf|cplx1/2/3/4/5/6/7|gabor_2d
	dynamics=dynamic,
%	af,%tanh|sin|cos|rbf|cplx1/2/3/4/5/6/7|gabor_2d
	neurodes=[],%[#neurode]
	tot_neurodes,%int()
	input,%[float()]
	output,%[float()]
	ivl,%int()
%	receptive_field=full,%full|int()
%	step=0,%int()
	encoder=[],%[neurode]
	decoder=[],%[#neurode]
	backprop_tuning=off,%off|on
	index_start,%int()
	index_end,%int()
	parameters=[]%[any()]
}).

-record(layer2,{
	id,%Z::float()
	i_pidps=[],
	o_pids=[],
	noise,
	type=dae,%{convolutional,VL}|{pooling,max|avg|min}|fully_connected|standard
	neurode_type=tanh,%tanh|sin|cos|rbf|cplx1/2/3/4/5/6/7|gabor_2d
%	af,%tanh|sin|cos|rbf|cplx1/2/3/4/5/6/7|gabor_2d
	dynamics=dynamic,
	neurodes=[],%[#neurode]
	tot_neurodes,%int() :: length(neurodes)
	input,%[float()]
	output,%[float()]
	ivl,%int()
	ovl,
	receptive_field=full,%full|int()
	step=0,%int()
%	encoder=[],%[neurode], this is the neurodes element
	decoder=[],%[#neurode]
	backprop_tuning=off,%off|on
	validation_err,%[float()]%In case of DAE
	testing_err,%[float()]%In case of DAE
	err_acc=0,
	block_size=100,%int()
	training_length=1000,
	parameters=[]%[any()]
}).

-record(layer_spec,{type,af,ivl,dynamics,receptive_field,step}).%[{dae|pooling|standard,af(),IVL::int(),static|dynamic,Receptive_Field::int(),Step::int()}]

-record(neurode,{
	id,%[X::float(),Y::float()]
	weights,%[float()]|[{float(),float(),float()}]
	i,
	af,%tanh|sin|cos|rbf|cplx1/2/3/4/5/6/7|gabor_2d
	bias,%float()|{float(),float(),float()}
	parameters=[],%list()
	dot_product%[float()]
}).

-record(constraint,{
	morphology=xor_mimic, %xor_mimic 
	connection_architecture = recurrent, %recurrent|feedforward 
	neural_afs=[
		tanh,
		cos,
		gaussian
		%sqrt
		%absolute
	], %[tanh,cos,gaussian,absolute,sin,sqrt,sigmoid],
%	neural_types = [standard], %[standard]
	neural_pfns=[none], %[none,hebbian_w,hebbian,ojas_w,ojas,self_modulationV1,self_modulationV2,self_modulationV2,self_modulationV3,self_modulationV4,self_modulationV5,self_modulationV6,neuromodulation]
	substrate_plasticities=[none],
	substrate_linkforms = [l2l_feedforward],%[l2l_feedfrward,jordan_recurrent,fully_connected]
	neural_aggr_fs=[dot_product], %[dot_product, mult_product, diff]
	tuning_selection_fs=[dynamic_random], %[all,all_random, recent,recent_random, lastgen,lastgen_random]
	tuning_duration_f={wsize_proportional,0.5}, %[{const,20},{nsize_proportional,0.5},{wsize_proportional,0.5}...]
	annealing_parameters=[0.5], %[1,0.9]
	perturbation_ranges=[1], %[0.5,1,2,3...]
	agent_encoding_types= [neural], %[neural,substrate]
	heredity_types = [darwinian], %[darwinian,lamarckian]
	mutation_operators= [
		%{mutate_weights,1},
		{add_bias,10}, 
		%{remove_bias,1}, 
%		{mutate_af,1}, 
		{add_outlink,40}, 
		{add_inlink,40}, 
		{add_neuron,40}, 
		{outsplice,40},
		%{insplice,40},
		{add_sensorlink,1},
		%{add_actuatorlink,1},
		{add_sensor,1}, 
		{add_actuator,1},
%		{mutate_plasticity_parameters,1},
		{add_cpp,1},
		{add_cep,1}
	], %[{mutate_weights,1}, {add_bias,1}, {remove_bias,1}, {mutate_af,1}, {add_outlink,1}, {remove_outLink,1}, {add_inlink,1}, {remove_inlink,1}, {add_sensorlink,1}, {add_actuatorlink,1}, {add_neuron,1}, {remove_neuron,1}, {outsplice,1}, {insplice,1}, {add_sensor,1}, {remove_sensor,1}, {add_actuator,1}, {remove_actuator,1},{mutate_plasticity_parameters,1}]
	tot_topological_mutations_fs = [{ncount_exponential,0.5}], %[{ncount_exponential,0.5},{ncount_linear,1}]
	population_evo_alg_f=generational, %[generational, steady_state]
	population_fitness_postprocessor_f=size_proportional, %[none,nsize_proportional]
	population_selection_f=hof_competition, %[competition,top3]
	specie_distinguishers=[tot_n],%[tot_n,tot_inlinks,tot_outlinks,tot_sensors,tot_actuators,pattern,tot_tanh,tot_sin,tot_cos,tot_gaus,tot_lin...]
	hof_distinguishers=[tot_n],%[tot_n,tot_inlinks,tot_outlinks,tot_sensors,tot_actuators,pattern,tot_tanh,tot_sin,tot_cos,tot_gaus,tot_lin...]
	objectives = [main_fitness,inverse_tot_n] %[main_fitness,problem_specific_fitness,other_optimization_factors...]
	%specie_size_limit=10
}).
-record(experiment,{
	id,
	backup_flag = true,
	pm_parameters,
	init_constraints,
	progress_flag=in_progress,
	trace_acc=[],
	run_index=1,
	tot_runs=10,
	notes,
	started={date(),time()},
	completed,
	interruptions=[]
}).

-record(pmp,{
	op_mode=gt,
	population_id=test,
	survival_percentage=0.5,
	specie_size_limit=10,
	init_specie_size=20,
	polis_id = mathema,
	generation_limit = 100,
	evaluations_limit = 100000,
	fitness_goal = inf,
	benchmarker_pid,
	committee_pid
}).
-define(SIGMOID, 'ticketsB').
%%%SCAPE RELATED%%%
-record(polis,{id,scape_ids=[],population_ids=[],specie_ids=[],dx_ids=[],parameters=[]}).
-record(scape,{id,type,physics,metabolics,sector2avatars,avatars=[],plants=[],walls=[],pillars=[],laws=[],anomolies=[],artifacts=[],objects=[],elements=[],atoms=[],scheduler=0}).
-record(sector,{id,type,scape_pid,sector_size,physics,metabolics,sector2avatars,avatars=[],plants=[],walls=[],pillars=[],laws=[],anomolies=[],artifacts=[],objects=[],elements=[],atoms=[]}).
-record(avatar,{id,sector,morphology,type,specie,energy=0,health=0,food=0,age=0,kills=0,loc,direction,r,mass,objects,vis=[],state,stats,actuators,sensors,sound,gestalt,spear}).
-record(object,{id,sector,type,color,loc,pivot,elements=[],parameters=[]}).
-record(circle,{id,sector,color,loc,pivot,r}).
-record(square,{id,sector,color,loc,pivot,r}).
-record(line,{id,sector,color,loc,pivot,coords}).
-record(e,{id,sector,v_id,type,loc,pivot}).%pivot
-record(a,{id,sector,v_id,type,loc,pivot,mass,properties}).
