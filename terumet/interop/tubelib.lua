local tube = 'tubelib:tubeS'
if tubelib.version < 2.0 then
    tube = 'tubelib:tube1'
end

local base_mach = terumet.machine

terumet.register_machine_upgrade('tubelib', 'Tube Support Upgrade', 'Allows machine to interface with tubelib tubes', 'Any machine with input/output', {tube})

local machine_check = function(machine, player_name)
    return machine and terumet.machine.has_upgrade(machine, 'tubelib')
    ---terumet.machine.has_auth(machine, player_name)
end

function push_item(machine, item, dir)
    if 
        machine.class.fsdef.battery_slot
        and (
            (
                dir == 'in'
                and item:get_definition().groups._terumetal_battery == 1
            )
            or (
                dir == 'out'
                and item:get_definition().groups._terumetal_battery == 2
            )
        ) then
        return tubelib.put_item(machine.meta, 'battery', item)
    end
    if 
        machine.class.fsdef.fuel_slot
        and (
            (
                dir == 'in'
                and item:get_definition().groups._terumetal_battery == 2
            )
            or (
                dir == 'out'
                and item:get_definition().groups._terumetal_battery == 1
            )
        ) then
        return tubelib.put_item(machine.meta, 'fuel', item)
    end
    if dir == 'in' and base_mach.has_ext_input(machine) then
        return false
    end
    return tubelib.put_item(machine.meta, dir, item)
end

local PUSH_FUNC = function (dir)
    return function(pos, side, item, player_name)
        local machine = terumet.machine.readonly_state(pos)
        if machine_check(machine) then
            local result = push_item(machine, item, dir)
            if result then machine.class.on_inventory_change(machine) end
            return result
        end
        return false
    end
end

local TUBELIB_MACHINE_DEF = {
    on_pull_item = function(pos, side, player_name)
        local machine = terumet.machine.readonly_state(pos)
        if machine_check(machine) then
            if machine.class.fsdef.battery_slot then
                local battery_item = tubelib.get_item(machine.meta, 'battery')
                if battery_item and not battery_item:is_empty() then
                    local battery_item_definition = battery_item:get_definition()
                    if battery_item_definition.groups._terumetal_battery == 2 then
                        return battery_item
                    else
                        machine.inv:set_stack('battery', 1, battery_item)
                    end
                end
            end
            if machine.class.fsdef.fuel_slot then
                local battery_item = tubelib.get_item(machine.meta, 'fuel')
                if battery_item and not battery_item:is_empty() then
                    local battery_item_definition = battery_item:get_definition()
                    if battery_item_definition.groups._terumetal_battery == 1 then
                        return battery_item
                    else
                        machine.inv:set_stack('fuel', 1, battery_item)
                    end
                end
            end
            if not base_mach.has_ext_output(machine) then
                local output_item = tubelib.get_item(machine.meta, 'out')
                if output_item and not output_item:is_empty() then
                    return output_item
                end
            end
        end
        return nil
    end,
    on_push_item = PUSH_FUNC('in'),
    on_unpull_item = PUSH_FUNC('out')
}

terumet.machine.register_on_place(function (pos, machine, placer)
    tubelib.add_node(pos, machine.class.name)
end)

terumet.machine.register_on_remove(function (pos, machine)
    tubelib.remove_node(pos)
end)

tubelib.register_node(terumet.id('mach_asmelt'), {terumet.id('mach_asmelt_lit')}, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_htfurn'), {terumet.id('mach_htfurn_lit')}, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_lavam'), {terumet.id('mach_lavam_lit')}, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_htr_furnace'), {terumet.id('mach_htr_furnace_lit')}, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_htr_solar'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_htr_entropy'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_crusher'), {terumet.id('mach_crusher_lit')}, TUBELIB_MACHINE_DEF)
--oops: mese garden has no upgrade slots... consider adding it if support for other upgrades is added in future
--tubelib.register_node(terumet.id('mach_meseg'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_repm'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_vulcan'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_vcoven'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_thermobox'), terumet.EMPTY, TUBELIB_MACHINE_DEF)
tubelib.register_node(terumet.id('mach_thermdist'), terumet.EMPTY, TUBELIB_MACHINE_DEF)