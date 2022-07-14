#!/usr/bin/env halmd
--
-- Copyright © 2011-2014 Felix Höfling
-- Copyright © 2010-2012 Peter Colberg
--
-- This file is part of HALMD.
--
-- HALMD is free software: you can redistribute it and/or modify
-- it under the terms of the GNU Lesser General Public License as
-- published by the Free Software Foundation, either version 3 of
-- the License, or (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU Lesser General Public License for more details.
--
-- You should have received a copy of the GNU Lesser General
-- Public License along with this program.  If not, see
-- <http://www.gnu.org/licenses/>.
--

-- grab modules
local log = halmd.io.log
local mdsim = halmd.mdsim
local numeric = halmd.numeric
local observables = halmd.observables
local random = halmd.random
local writers = halmd.io.writers
local readers = halmd.io.readers
local utility = halmd.utility
local random1 = math.random
math.randomseed(os.time())
-- Setup and run simulation
--
function main(args)
    -- total number of particles from sum of particles
    local nparticle = numeric.sum(args.particles)
	
    local length = {}
    	length[1]=100
	length[2]=40
	length[3]=40

    local dimension = 3
    -- create simulation domain with periodic boundary conditions
    local box = mdsim.box({length = length})
   

    -- create system state
    local particle = mdsim.particle({dimension = dimension, particles = nparticle})

    -- set initial particle positions sequentially on an fcc lattice
    local lattice = mdsim.positions.lattice({box = box, particle = particle})
    lattice:set()
    positions = particle.data["position"]
    print(positions)

    -- select all particles
    local all_group = mdsim.particle_groups.all({particle = particle, label="all"})

    --****************************************

    -- H5MD file writer
    local file = writers.h5md({path = ("particle_box.h5"):format(args.output), overwrite = args.overwrite})


end

--
-- Parse command-line arguments.
--
function define_args(parser)
    parser:add_argument("output,o", {type = "string", action = parser.action.substitute_date_time,
        default = "Mixeq_density_0.3.h5", help = "prefix of output files"})
    parser:add_argument("overwrite", {type = "boolean", default = false, help = "overwrite output file"})

    parser:add_argument("particles", {type = "vector", dtype = "integer", default = {67334}, help = "number of particles"})
    parser:add_argument("density", {type = "number", default = 0.35, help = "particle number density"})
    parser:add_argument("ratios", {type = "vector", dtype = "number", action = function(args, key, value)
        if #value ~= 2 and #value ~= 3 then
            error(("box ratios has invalid dimension '%d'"):format(#value), 0)
        end
        args[key] = value
    end, default = {1, 1, 1}, help = "relative aspect ratios of simulation box"})
    parser:add_argument("masses", {type = "vector", dtype = "number", default = {1}, help = "particle masses"})
    parser:add_argument("initial-temperature", {type = "number", default = 1.5, help = "initial temperature"})
    parser:add_argument("temperature", {type = "number", default = 1, help = "target temperature"})
    parser:add_argument("rate", {type = "number", default = 4, help = "heat bath collision rate"})
    parser:add_argument("time", {type = "number", default =10 , help = "integration time"})
    parser:add_argument("timestep", {type = "number", default = 0.005, help = "integration time step"})

    local sampling = parser:add_argument_group("sampling", {help = "sampling intervals (0: disabled)"})
    sampling:add_argument("trajectory", {type = "integer", help = "for trajectory"})
    sampling:add_argument("state-vars", {type = "integer", default = 10, help = "for state variables"})
end
