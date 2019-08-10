
-- Copyright (C) 2015-2019 DBotThePony

-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
-- of the Software, and to permit persons to whom the Software is furnished to do so,
-- subject to the following conditions:

-- The above copyright notice and this permission notice shall be included in all copies
-- or substantial portions of the Software.

-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

import DPP2, DLib from _G

empty = {}
stuffCache = {}

findStuff = (path) ->
	if not stuffCache[path]
		ffiles, fdirs = select(1, file.Find(path .. '/*.mdl', 'GAME')), select(2, file.Find(path .. '/*', 'GAME'))

		if not ffiles
			stuffCache[path] = {}
			return stuffCache[path]

		table.appendString(fdirs, '/')
		table.append(ffiles, fdirs)
		stuffCache[path] = ffiles

	return stuffCache[path]

DPP2.ModelAutocomplete = (args, margs, excludelist = empty) =>
	args = args\lower()\gsub('//', '/')
	return {'models/'} if (args == '' or #args < 7) and args ~= 'models/'

	findDir = args\split('/')
	filename = table.remove(findDir)
	dpath = table.concat(findDir, '/')
	findFiles = findStuff(dpath)

	output = {}

	for filename2 in *findFiles
		with lower = filename2\lower()
			if not table.qhasValue(excludelist, lower) and not table.qhasValue(excludelist, filename2)
				if lower == filename
					output = {string.format('%s/%s', dpath, filename2)}
					break

				if lower\startsWith(filename)
					table.insert(output, string.format('%s/%s', dpath, filename2))

	return output

def = {
	'ai_addon_builder', 'ai_ally_manager', 'ai_battle_line', 'ai_changehintgroup', 'ai_changetarget', 'ai_citizen_response_system', 'ai_goal_actbusy', 'ai_goal_actbusy_queue', 'ai_goal_assault', 'ai_goal_fightfromcover',
	'ai_goal_follow', 'ai_goal_injured_follow', 'ai_goal_lead', 'ai_goal_lead_weapon', 'ai_goal_operator', 'ai_goal_police', 'ai_goal_standoff', 'ai_network', 'ai_npc_eventresponsesystem', 'ai_relationship', 'ai_script_conditions',
	'ai_sound', 'ai_speechfilter', 'aiscripted_schedule', 'aitesthull', 'ambient_generic', 'ambient_generic_(goldsource_engine)', 'ambient_music', 'ammo_357_(goldsource_engine)', 'ammo_357sig', 'ammo_45acp', 'ammo_50ae',
	'ammo_556mm', 'ammo_556mm_box', 'ammo_57mm', 'ammo_762mm', 'ammo_9mm', 'ammo_buckshot', 'apc_missile', 'ar2explosion', 'assault_assaultpoint', 'assault_rallypoint', 'asw_alien_goo',
	'asw_ammo_rifle', 'asw_bloodhound', 'asw_camera_control', 'asw_debrief_info', 'asw_director_control', 'asw_door', 'asw_emitter', 'asw_env_explosion', 'asw_env_shake', 'asw_equip_req', 'asw_grub',
	'asw_holdout_mode', 'asw_holdout_spawner', 'asw_info_message', 'asw_marine', 'asw_marker', 'asw_objective_countdown', 'asw_objective_destroy_goo', 'asw_objective_escape', 'asw_objective_triggered', 'asw_order_nearby_aliens', 'asw_pickup_ammo_bag',
	'asw_pickup_autogun', 'asw_pickup_chainsaw', 'asw_pickup_fire_extinguisher', 'asw_pickup_flamer', 'asw_pickup_flares', 'asw_pickup_flashlight', 'asw_pickup_grenades', 'asw_pickup_medkit', 'asw_pickup_mines', 'asw_pickup_mining_laser', 'asw_pickup_pdw',
	'asw_pickup_pistol', 'asw_pickup_prifle', 'asw_pickup_railgun', 'asw_pickup_rifle', 'asw_pickup_sentry', 'asw_pickup_shotgun', 'asw_pickup_stim', 'asw_pickup_vindicator', 'asw_pickup_welder', 'asw_polytest', 'asw_remote_turret',
	'asw_snow_volume', 'asw_spawner', 'asw_tech_marine_req', 'asw_trigger_fall', 'asw_vehicle_jeep', 'asw_weapon_blink', 'asw_weapon_jump_jet', 'basehlcombatweapon', 'baseprojectile', 'basic_the_ship_entities', 'beam',
	'beam_spotlight', 'blob_element', 'bodyque', 'bot_action_point', 'bot_controller', 'bot_generator', 'bot_hint_engineer_nest', 'bot_hint_sentrygun', 'bot_hint_teleporter_exit', 'bot_npc_archer', 'bot_proxy',
	'bot_roster', 'bounce_bomb', 'bullseye_strider_focus', 'chicken', 'color_correction_(entity)', 'color_correction_volume', 'combine_bouncemine', 'combine_mine', 'commentary_auto', 'commentary_dummy', 'commentary_zombie_spawner',
	'concussiveblast', 'constraint', 'cycler', 'cycler_(goldsource_engine)', 'cycler_actor', 'cycler_weapon_(goldsource_engine)', 'dark_messiah_entities', 'dispenser_touch_trigger', 'dod_bomb_dispenser', 'dod_bomb_target', 'dod_capture_area',
	'dod_control_point', 'dod_control_point_master', 'dod_location', 'dod_scoring', 'dronegun', 'dynamic_prop', 'dz_door', 'ent_hover_turret_tether', 'entity', 'entity_article_template', 'entity_spawn_manager',
	'entity_spawn_point', 'entityflame', 'env_airstrike_indoors', 'env_airstrike_outdoors', 'env_alyxemp', 'env_ambient_light', 'env_ar2explosion', 'env_beam', 'env_beverage', 'env_blood', 'env_bubbles',
	'env_cascade_light', 'env_citadel_energy_core', 'env_credits', 'env_cubemap', 'env_detail_controller', 'env_dof_controller', 'env_dustpuff', 'env_dusttrail', 'env_effectscript', 'env_embers', 'env_entity_dissolver',
	'env_entity_igniter', 'env_entity_maker', 'env_explosion', 'env_extinguisherjet', 'env_fade', 'env_faint', 'env_fire', 'env_firesensor', 'env_firesource', 'env_flare', 'env_fog_controller',
	'env_funnel', 'env_global', 'env_global_(goldsource_engine)', 'env_global_light', 'env_glow', 'env_gunfire', 'env_headcrabcanister', 'env_hudhint', 'env_instructor_hint', 'env_laser', 'env_lightglow',
	'env_lightrail_endpoint', 'env_message', 'env_microphone', 'env_muzzleflash', 'env_outtro_stats', 'env_particle_performance_monitor', 'env_particlelight', 'env_particlescript', 'env_physexplosion', 'env_physics_blocker', 'env_physimpact',
	'env_player_blocker', 'env_player_surface_trigger', 'env_player_viewfinder', 'env_poison_gas', 'env_portal_credits', 'env_portal_laser', 'env_portal_path_track', 'env_projectedtexture', 'env_radio', 'env_radio_message', 'env_render',
	'env_rock_launcher', 'env_rotorshooter', 'env_rotorwash_emitter', 'env_screeneffect', 'env_screenoverlay', 'env_shake', 'env_shooter', 'env_slomo', 'env_smokestack', 'env_smoketrail', 'env_soundscape',
	'env_soundscape_proxy', 'env_spark', 'env_speaker', 'env_splash', 'env_sporeexplosion', 'env_sprite', 'env_sprite_clientside', 'env_sprite_oriented', 'env_spritetrail', 'env_starfield', 'env_steam',
	'env_sun', 'env_terrainmorph', 'env_texturetoggle', 'env_tilt', 'env_tonemap_controller', 'env_tonemap_controller_ghost', 'env_tonemap_controller_infected', 'env_tracer', 'env_viewpunch', 'env_warpball', 'env_weaponfire',
	'env_wind', 'env_zoom', 'eyeball_boss', 'filter_activator_class', 'filter_activator_context', 'filter_activator_infected_class', 'filter_activator_mass_greater', 'filter_activator_model', 'filter_activator_name', 'filter_activator_team', 'filter_activator_tfteam',
	'filter_base', 'filter_combineball_type', 'filter_damage_type', 'filter_enemy', 'filter_health', 'filter_melee_damage', 'filter_multi', 'filter_player_held', 'filter_tf_bot_has_tag', 'filter_tf_class', 'filter_tf_condition',
	'filter_tf_damaged_by_weapon_in_slot', 'filter_tf_player_can_cap', 'fish', 'fog_volume', 'func_achievement', 'func_areaportal', 'func_areaportalwindow', 'func_block_charge', 'func_bomb_target', 'func_breakable', 'func_breakable_(goldsource_engine)',
	'func_breakable_surf', 'func_brush', 'func_buildable_button', 'func_bulletshield', 'func_button', 'func_button_timed', 'func_buyzone', 'func_capturezone', 'func_changeclass', 'func_clip_vphysics', 'func_combine_ball_spawner',
	'func_conveyor', 'func_croc', 'func_detail', 'func_detail_blocker', 'func_door', 'func_door_rotating', 'func_dustcloud', 'func_dustmotes', 'func_elevator', 'func_extinguisher', 'func_fire_extinguisher',
	'func_fish_pool', 'func_flag_alert', 'func_flagdetectionzone', 'func_footstep_control', 'func_forcefield', 'func_guntarget', 'func_healthcharger', 'func_hostage_rescue', 'func_humanclip', 'func_illusionary', 'func_instance',
	'func_instance_io_proxy', 'func_instance_origin', 'func_instance_parms', 'func_ladder', 'func_ladderendpoint', 'func_liquidportal', 'func_lod', 'func_lookdoor', 'func_monitor', 'func_movelinear', 'func_nav_attribute_region',
	'func_nav_avoid', 'func_nav_avoidance_obstacle', 'func_nav_connection_blocker', 'func_nav_prefer', 'func_nav_prerequisite', 'func_nav_stairs_toggle', 'func_no_defuse', 'func_nobuild', 'func_nogrenades', 'func_noportal_volume', 'func_occluder',
	'func_orator', 'func_passtime_goal', 'func_passtime_no_ball_zone', 'func_pendulum_(goldsource_engine)', 'func_physbox', 'func_physbox_multiplayer', 'func_placement_clip', 'func_plat', 'func_platrot', 'func_playerghostinfected_clip', 'func_playerinfected_clip',
	'func_portal_bumper', 'func_portal_detector', 'func_portal_orientation', 'func_portalled', 'func_precipitation', 'func_precipitation_blocker', 'func_proprespawnzone', 'func_pushable_(goldsource_engine)', 'func_ragdoll_fader', 'func_recharge', 'func_reflective_glass',
	'func_regenerate', 'func_respawnflag', 'func_respawnroom', 'func_respawnroomvisualizer', 'func_rot_button', 'func_rotating', 'func_simpleladder', 'func_smokevolume', 'func_spawn_volume', 'func_suggested_build', 'func_survival_c4_target',
	'func_tablet_blocker', 'func_tank', 'func_tank_combine_cannon', 'func_tankairboatgun', 'func_tankapcrocket', 'func_tanklaser', 'func_tankmortar', 'func_tankphyscannister', 'func_tankpulselaser', 'func_tankrocket', 'func_tanktrain',
	'func_team_wall', 'func_teamblocker', 'func_tfbot_hint', 'func_timescale', 'func_trackautochange', 'func_trackchange', 'func_tracktrain', 'func_train', 'func_traincontrols', 'func_upgradestation', 'func_useableladder',
	'func_vehicleclip', 'func_viscluster', 'func_wall', 'func_wall_toggle', 'func_water', 'func_water_analog', 'func_weight_button', 'func_zombieclip', 'funcbaseflex', 'game_coopmission_manager', 'game_end',
	'game_forcerespawn', 'game_gib_manager', 'game_intro_viewpoint', 'game_money', 'game_player_equip', 'game_player_team', 'game_ragdoll_manager', 'game_round_end', 'game_round_win', 'game_scavenge_progress_display', 'game_score',
	'game_survival_logic', 'game_text', 'game_text_tf', 'game_ui', 'game_weapon_manager', 'game_win_human', 'game_win_zombie', 'game_zone_player', 'generic_actor', 'generic_monster', 'ghost',
	'gibshooter', 'grenade_ar2', 'grenade_helicopter', 'halloween_fortune_teller', 'halloween_zapper', 'hammer_updateignorelist', 'headless_hatman', 'hegrenade_projectile', 'hint_nodes', 'hostage_entity', 'info_ambient_mob',
	'info_apc_missile_hint', 'info_beacon', 'info_bigmomma_(goldsource_engine)', 'info_camera_link', 'info_challenge', 'info_changelevel', 'info_constraint_anchor', 'info_coop_spawn', 'info_darknessmode_lightsource', 'info_deathmatch_spawn', 'info_director',
	'info_doddetect', 'info_elevator_floor', 'info_enemy_terrorist_spawn', 'info_game_event_proxy', 'info_gamemode', 'info_gascanister_launchpoint', 'info_goal_infected_chase', 'info_hint', 'info_intermission', 'info_item_position', 'info_l4d1_survivor_spawn',
	'info_ladder_dismount', 'info_landmark', 'info_landmark_entry', 'info_landmark_exit', 'info_lighting', 'info_lighting_relative', 'info_map_parameters', 'info_map_parameters_versus', 'info_map_region', 'info_mass_center', 'info_no_dynamic_shadow',
	'info_node', 'info_node_air', 'info_node_air_hint', 'info_node_climb', 'info_node_hint', 'info_node_link', 'info_node_link_controller', 'info_npc_spawn_destination', 'info_null', 'info_null_(goldsource_engine)', 'info_objective_list',
	'info_observer_point', 'info_overlay', 'info_overlay_accessor', 'info_overlay_transition', 'info_paint_sprayer', 'info_particle_system', 'info_particle_target', 'info_passtime_ball_spawn', 'info_placement_helper', 'info_player_allies', 'info_player_axis',
	'info_player_combine', 'info_player_common', 'info_player_counterterrorist', 'info_player_deathmatch', 'info_player_human', 'info_player_logo', 'info_player_observer', 'info_player_ping_detector', 'info_player_rebel', 'info_player_start', 'info_player_start_(goldsource_engine)',
	'info_player_teamspawn', 'info_player_terrorist', 'info_player_zombie', 'info_powerup_spawn', 'info_projecteddecal', 'info_radar_target', 'info_radial_link_controller', 'info_remarkable', 'info_snipertarget', 'info_survivor_position', 'info_survivor_rescue',
	'info_target', 'info_target_gunshipcrash', 'info_target_helicopter_crash', 'info_target_instructor_hint', 'info_target_personality_sphere', 'info_target_vehicle_transition', 'info_target_viewproxy', 'info_teleport_destination', 'info_teleporter_countdown', 'info_texlights_(goldsource_engine)', 'info_view_parameters',
	'info_zombie_border', 'info_zombie_spawn', 'infodecal', 'infra_button', 'infra_camera_target', 'infra_corruption_target', 'infra_crow', 'infra_document', 'infra_flowmap_modify', 'infra_geocache', 'infra_music',
	'infra_water_flow_meter_target', 'item_ammo_357', 'item_ammo_357_large', 'item_ammo_ar', 'item_ammo_ar_grenade', 'item_ammo_ar2', 'item_ammo_ar2_altfire', 'item_ammo_ar2_large', 'item_ammo_buckshot', 'item_ammo_crate', 'item_ammo_crossbow',
	'item_ammo_duag', 'item_ammo_flak', 'item_ammo_magnum', 'item_ammo_pistol', 'item_ammo_pistol_large', 'item_ammo_smg1', 'item_ammo_smg1_grenade', 'item_ammo_smg1_large', 'item_ammopack_full', 'item_ammopack_medium', 'item_ammopack_small',
	'item_antigen_dispenser', 'item_assaultsuit', 'item_battery', 'item_bonuspack', 'item_box_buckshot', 'item_cash', 'item_coop_coin', 'item_currencypack_large', 'item_currencypack_medium', 'item_currencypack_small', 'item_defuser',
	'item_dynamic_resupply', 'item_healthcharger', 'item_healthkit', 'item_healthkit_full', 'item_healthkit_medium', 'item_healthkit_small', 'item_healthvial', 'item_item_crate', 'item_kevlar', 'item_megahealth', 'item_nvgs',
	'item_paint_power_pickup', 'item_powerup_temp', 'item_rpg_round', 'item_sodacan', 'item_suit', 'item_suitcharger', 'item_teamflag', 'item_thighpack', 'keyframe_rope', 'keyframe_track', 'light',
	'light_(goldsource_engine)', 'light_directional', 'light_dynamic', 'light_environment', 'light_glspot', 'light_spot', 'linked_portal_door', 'logic_achievement', 'logic_active_autosave', 'logic_auto', 'logic_autosave',
	'logic_branch', 'logic_branch_listener', 'logic_case', 'logic_choreographed_scene', 'logic_collision_pair', 'logic_compare', 'logic_coop_manager', 'logic_director_query', 'logic_eventlistener', 'logic_game_event', 'logic_lineto',
	'logic_measure_movement', 'logic_menulistener', 'logic_multicompare', 'logic_navigation', 'logic_playerproxy', 'logic_playmovie', 'logic_random_outputs', 'logic_register_activator', 'logic_relay', 'logic_scene_list_manager', 'logic_script',
	'logic_timer', 'logic_timescale', 'logic_versus_random', 'lua_run', 'mapobj_cart_dispenser', 'material_modify_control', 'math_colorblend', 'math_counter', 'math_remap', 'merasmus', 'momentary_rot_button',
	'monster_babycrab', 'monster_bigmomma_(goldsource_engine)', 'monster_generic', 'move_keyframed', 'move_rope', 'move_track', 'multisource', 'npc_advisor', 'npc_alyx', 'npc_antlion', 'npc_antlion_grub',
	'npc_antlion_template_maker', 'npc_antliongrub', 'npc_antlionguard', 'npc_apcdriver', 'npc_barnacle', 'npc_barney', 'npc_blob', 'npc_breen', 'npc_bullseye', 'npc_bullsquid', 'npc_citizen',
	'npc_clawscanner', 'npc_combine_advisor_roaming', 'npc_combine_camera', 'npc_combine_cannon', 'npc_combine_s', 'npc_combinedropship', 'npc_combinegunship', 'npc_crabsynth', 'npc_cranedriver', 'npc_cremator', 'npc_crow',
	'npc_cscanner', 'npc_dog', 'npc_eli', 'npc_enemyfinder', 'npc_enemyfinder_combinecannon', 'npc_fastzombie', 'npc_fastzombie_torso', 'npc_fisherman', 'npc_furniture', 'npc_gman', 'npc_grenade_bugbait',
	'npc_grenade_frag', 'npc_headcrab', 'npc_headcrab_black', 'npc_headcrab_fast', 'npc_heli_avoidbox', 'npc_heli_avoidsphere', 'npc_heli_nobomb', 'npc_helicopter', 'npc_hover_turret', 'npc_hunter', 'npc_ichthyosaur',
	'npc_kleiner', 'npc_launcher', 'npc_magnusson', 'npc_maker', 'npc_manhack', 'npc_metropolice', 'npc_ministrider', 'npc_missiledefense', 'npc_monk', 'npc_mortarsynth', 'npc_mossman',
	'npc_particlestorm', 'npc_personality_core', 'npc_pigeon', 'npc_poisonzombie', 'npc_portal_turret_floor', 'npc_portal_turret_ground', 'npc_puppet', 'npc_rocket_turret', 'npc_rollermine', 'npc_seagull', 'npc_security_camera',
	'npc_sniper', 'npc_spotlight', 'npc_stalker', 'npc_strider', 'npc_template_maker', 'npc_turret_ceiling', 'npc_turret_floor', 'npc_turret_ground', 'npc_vehicledriver', 'npc_vortigaunt', 'npc_wheatley_boss',
	'npc_zombie', 'npc_zombie_torso', 'npc_zombine', 'obj_dispenser', 'obj_sentrygun', 'obj_teleporter', 'paint_sphere', 'paint_stream', 'passtime_ball', 'path_corner', 'path_track',
	'pet_entity', 'phys_ballsocket', 'phys_bone_follower', 'phys_constraint', 'phys_constraintsystem', 'phys_convert', 'phys_hinge', 'phys_keepupright', 'phys_lengthconstraint', 'phys_magnet', 'phys_motor',
	'phys_pulleyconstraint', 'phys_ragdollconstraint', 'phys_ragdollmagnet', 'phys_slideconstraint', 'phys_spring', 'phys_thruster', 'phys_torque', 'physics_cannister', 'physics_prop', 'physics_prop_ragdoll', 'planted_c4_training',
	'plasma', 'player', 'player_loadsaved', 'player_speedmod', 'player_weapon_strip', 'player_weaponstrip', 'point_anglesensor', 'point_angularvelocitysensor', 'point_antlion_repellant', 'point_apc_controller', 'point_bonusmaps_accessor',
	'point_broadcastclientcommand', 'point_bugbait', 'point_camera', 'point_changelevel', 'point_clientcommand', 'point_combine_ball_launcher', 'point_commentary_node', 'point_deathfall_camera', 'point_devshot_camera', 'point_dz_dronegun', 'point_dz_parachute',
	'point_dz_weaponspawn', 'point_enable_motion_fixup', 'point_energy_ball_launcher', 'point_entity_finder', 'point_event_proxy', 'point_flesh_effect_target', 'point_futbol_shooter', 'point_gamestats_counter', 'point_give_ammo', 'point_hiding_spot', 'point_hurt',
	'point_intermission', 'point_laser_target', 'point_message', 'point_nav_attribute_region', 'point_playermoveconstraint', 'point_populator_interface', 'point_posecontroller', 'point_prop_use_target', 'point_proximity_sensor', 'point_push', 'point_script_use_target',
	'point_servercommand', 'point_spotlight', 'point_surroundtest', 'point_teleport', 'point_template', 'point_tesla', 'point_velocitysensor', 'point_viewcontrol', 'point_viewcontrol_(infra)', 'point_viewcontrol_multiplayer', 'point_viewcontrol_node',
	'point_viewcontrol_survivor', 'point_viewproxy', 'point_worldtext', 'portalmp_gamerules', 'postprocess_controller', 'projected_tractor_beam_entity', 'projected_wall_entity', 'prop_ammo_box_generic', 'prop_antigen_explosive_barrel', 'prop_button', 'prop_car_alarm',
	'prop_car_glass', 'prop_combine_ball', 'prop_coreball', 'prop_counter', 'prop_detail', 'prop_detail_sprite', 'prop_door_rotating', 'prop_door_rotating_checkpoint', 'prop_dynamic', 'prop_dynamic_glow', 'prop_dynamic_ornament',
	'prop_dynamic_override', 'prop_exploding_futbol', 'prop_exploding_futbol_spawner', 'prop_floor_ball_button', 'prop_floor_button', 'prop_floor_cube_button', 'prop_fuel_barrel', 'prop_glados_core', 'prop_glass_futbol', 'prop_glass_futbol_spawner', 'prop_glowing_object',
	'prop_hallucination', 'prop_health_cabinet', 'prop_indicator_panel', 'prop_laser_catcher', 'prop_laser_relay', 'prop_linked_portal_door', 'prop_loot_crate', 'prop_metal_crate', 'prop_minigun', 'prop_minigun_l4d1', 'prop_mirror',
	'prop_money_crate', 'prop_monster_box', 'prop_mounted_machine_gun', 'prop_oxygen_tank', 'prop_paint_bomb', 'prop_phone', 'prop_physics', 'prop_physics_multiplayer', 'prop_physics_override', 'prop_physics_paintable', 'prop_physics_respawnable',
	'prop_portal', 'prop_portal_stats_display', 'prop_propane_tank', 'prop_ragdoll', 'prop_rocket_tripwire', 'prop_scalable', 'prop_scaled_cube', 'prop_sphere', 'prop_static', 'prop_stickybomb', 'prop_telescopic_arm',
	'prop_testchamber_door', 'prop_thumper', 'prop_tic_tac_toe_panel', 'prop_tractor_beam', 'prop_u4_barrel', 'prop_under_button', 'prop_under_floor_button', 'prop_vehicle', 'prop_vehicle_airboat', 'prop_vehicle_apc', 'prop_vehicle_cannon',
	'prop_vehicle_choreo_generic', 'prop_vehicle_crane', 'prop_vehicle_driveable', 'prop_vehicle_jeep', 'prop_vehicle_prisoner_pod', 'prop_vehicle_sin', 'prop_wall_breakable', 'prop_wall_projector', 'prop_weapon_upgrade_armor_helmet', 'prop_weapon_upgrade_chute', 'prop_weapon_upgrade_contractkill',
	'prop_weapon_upgrade_tablet_droneintel', 'prop_weapon_upgrade_tablet_highres', 'prop_weapon_upgrade_tablet_zoneintel', 'prop_weighted_cube', 'rpg_missile', 'script_intro', 'script_tauremoval', 'scripted_item_drop', 'scripted_sentence', 'scripted_sequence', 'scripted_target',
	'shadow_control', 'simple_physics_brush', 'simple_physics_prop', 'sky_camera', 'skybox_swapper', 'sound_mix_layer', 'standoffs', 'sunlight_shadow_control', 'tank_boss', 'tanktrain_ai', 'tanktrain_aitarget',
	'team_control_point', 'team_control_point_master', 'team_control_point_round', 'team_round_timer', 'team_train_watcher', 'test_effect', 'test_sidelist', 'test_traceline', 'tf_base_minigame', 'tf_gamerules', 'tf_generic_bomb',
	'tf_glow', 'tf_logic_arena', 'tf_logic_boss_battle', 'tf_logic_cp_timer', 'tf_logic_gasworks', 'tf_logic_holiday', 'tf_logic_hybrid_ctf_cp', 'tf_logic_koth', 'tf_logic_mann_vs_machine', 'tf_logic_medieval', 'tf_logic_multiple_escort',
	'tf_logic_player_destruction', 'tf_logic_raid', 'tf_logic_robot_destruction', 'tf_logic_training_mode', 'tf_point_nav_interface', 'tf_point_weapon_mimic', 'tf_populator', 'tf_projectile_arrow', 'tf_projectile_flare', 'tf_projectile_healing_bolt', 'tf_projectile_jar',
	'tf_projectile_jar_milk', 'tf_projectile_rocket', 'tf_projectile_sentryrocket', 'tf_projectile_stun_ball', 'tf_pumpkin_bomb', 'tf_robot_destruction_robot_spawn', 'tf_robot_destruction_spawn_group', 'tf_spawner', 'tf_spell_pickup', 'tf_weapon_bat', 'tf_weapon_bat_fish',
	'tf_weapon_bat_giftwrap', 'tf_weapon_bat_wood', 'tf_weapon_bonesaw', 'tf_weapon_bottle', 'tf_weapon_cannon', 'tf_weapon_club', 'tf_weapon_compound_bow', 'tf_weapon_crossbow', 'tf_weapon_fireaxe', 'tf_weapon_fists', 'tf_weapon_grenadelauncher',
	'tf_weapon_handgun_scout_primary', 'tf_weapon_jar', 'tf_weapon_jar_milk', 'tf_weapon_katana', 'tf_weapon_knife', 'tf_weapon_laser_pointer', 'tf_weapon_medigun', 'tf_weapon_minigun', 'tf_weapon_pda_engineer_build', 'tf_weapon_pda_engineer_destroy', 'tf_weapon_pda_spy',
	'tf_weapon_rocketlauncher', 'tf_weapon_rocketlauncher_directhit', 'tf_weapon_sentry_revenge', 'tf_weapon_shotgun_building_rescue', 'tf_weapon_shovel', 'tf_weapon_smg', 'tf_weapon_soda_popper', 'tf_weapon_stickbomb', 'tf_weapon_sword', 'tf_weapon_wrench', 'tf_wearable',
	'tf_wearable_demoshield', 'tf_zombie', 'tf_zombie_spawner', 'training_annotation', 'trigger_active_weapon_detect', 'trigger_add_or_remove_tf_player_attributes', 'trigger_add_tf_player_condition', 'trigger_apply_impulse', 'trigger_asw_button_area', 'trigger_asw_chance', 'trigger_asw_computer_area',
	'trigger_asw_door_area', 'trigger_asw_jump', 'trigger_asw_marine_knockback', 'trigger_asw_marine_position', 'trigger_asw_random_target', 'trigger_asw_supply_chatter', 'trigger_asw_synup_chatter', 'trigger_auto_crouch', 'trigger_autosave', 'trigger_autosave_(goldsource_engine)', 'trigger_bomb_reset',
	'trigger_bot_tag', 'trigger_brush', 'trigger_capture_area', 'trigger_catapult', 'trigger_changelevel', 'trigger_escape', 'trigger_finale', 'trigger_finale_dlc3', 'trigger_fog', 'trigger_gravity', 'trigger_hierarchy',
	'trigger_hurt', 'trigger_hurt_ghost', 'trigger_ignite', 'trigger_ignite_arrows', 'trigger_impact', 'trigger_joinhumanteam', 'trigger_joinspectatorteam', 'trigger_joinzombieteam', 'trigger_look', 'trigger_multiple', 'trigger_once',
	'trigger_paint_cleanser', 'trigger_physics_trap', 'trigger_ping_detector', 'trigger_player_respawn_override', 'trigger_playermovement', 'trigger_playerteam', 'trigger_portal_cleanser', 'trigger_proximity', 'trigger_push', 'trigger_rd_vault_trigger', 'trigger_remove',
	'trigger_rpgfire', 'trigger_secret', 'trigger_serverragdoll', 'trigger_softbarrier', 'trigger_soundscape', 'trigger_standoff', 'trigger_stun', 'trigger_super_armor', 'trigger_teleport', 'trigger_teleport_relative', 'trigger_timer_door',
	'trigger_togglesave', 'trigger_tonemap', 'trigger_transition', 'trigger_upgrade_laser_sight', 'trigger_vphysics_motion', 'trigger_waterydeath', 'trigger_weapon_dissolve', 'trigger_weapon_strip', 'trigger_wind', 'updateitem2', 'upgrade_spawn',
	'vehicle_viewcontroller', 'vgui_level_placard_display', 'vgui_movie_display', 'vgui_mp_lobby_display', 'vgui_neurotoxin_countdown', 'vgui_screen', 'vgui_slideshow_display', 'water_lod_control',
}

def_weapons = {
	'weapon_30cal', 'weapon_357', 'weapon_adrenaline_spawn', 'weapon_ak47', 'weapon_alyxgun', 'weapon_amerknife', 'weapon_ammo_spawn', 'weapon_annabelle', 'weapon_ar2', 'weapon_assault_rifle',
	'weapon_aug', 'weapon_autoshotgun_spawn', 'weapon_awp', 'weapon_bar', 'weapon_basebomb', 'weapon_bazooka', 'weapon_bizon', 'weapon_brickbat', 'weapon_bugbait', 'weapon_c4', 'weapon_c96',
	'weapon_chainsaw_spawn', 'weapon_citizenpackage', 'weapon_citizensuitcase', 'weapon_colt', 'weapon_crossbow', 'weapon_cubemap', 'weapon_cz75a', 'weapon_deagle', 'weapon_decoy', 'weapon_defibrillator_spawn', 'weapon_elite',
	'weapon_famas', 'weapon_first_aid_kit_spawn', 'weapon_fiveseven', 'weapon_flashbang', 'weapon_frag', 'weapon_g3sg1', 'weapon_galil', 'weapon_galilar', 'weapon_garand', 'weapon_gascan_spawn', 'weapon_glock',
	'weapon_grenade', 'weapon_grenade_launcher_spawn', 'weapon_healthshot', 'weapon_hegrenade', 'weapon_hkp2000', 'weapon_hunting_rifle_spawn', 'weapon_incgrenade', 'weapon_item_spawn', 'weapon_k98', 'weapon_k98s', 'weapon_knife',
	'weapon_knifegg', 'weapon_m1carb', 'weapon_m249', 'weapon_m3', 'weapon_m4a1', 'weapon_m4a1_silencer', 'weapon_mac10', 'weapon_mag7', 'weapon_magnum', 'weapon_melee_spawn', 'weapon_mg42',
	'weapon_molotov', 'weapon_molotov_spawn', 'weapon_mp40', 'weapon_mp44', 'weapon_mp5navy', 'weapon_mp5sd', 'weapon_mp7', 'weapon_mp9', 'weapon_negev', 'weapon_nova', 'weapon_p228',
	'weapon_p250', 'weapon_p38', 'weapon_p90', 'weapon_pain_pills_spawn', 'weapon_paintgun', 'weapon_physcannon', 'weapon_pipe_bomb_spawn', 'weapon_pistol', 'weapon_pistol_magnum_spawn', 'weapon_pistol_spawn', 'weapon_portalgun',
	'weapon_pschreck', 'weapon_pumpshotgun_spawn', 'weapon_revolver', 'weapon_rifle_ak47_spawn', 'weapon_rifle_desert_spawn', 'weapon_rifle_m60_spawn', 'weapon_rifle_spawn', 'weapon_rpg', 'weapon_sawedoff', 'weapon_scar20', 'weapon_scattergun',
	'weapon_scavenge_item_spawn', 'weapon_scout', 'weapon_sg550', 'weapon_sg552', 'weapon_sg556', 'weapon_shield', 'weapon_shotgun', 'weapon_shotgun_chrome_spawn', 'weapon_shotgun_spas_spawn', 'weapon_slam', 'weapon_smg_silenced_spawn',
	'weapon_smg_spawn', 'weapon_smg1', 'weapon_smokeger', 'weapon_smokegrenade', 'weapon_smokeus', 'weapon_sniper_military_spawn', 'weapon_spade', 'weapon_spawn', 'weapon_spring', 'weapon_ssg08', 'weapon_striderbuster',
	'weapon_stunstick', 'weapon_tagrenade', 'weapon_taser', 'weapon_tec9', 'weapon_thompson', 'weapon_tmp', 'weapon_ump45', 'weapon_upgradepack_explosive_spawn', 'weapon_upgradepack_incendiary_spawn', 'weapon_usp', 'weapon_usp_silencer',
	'weapon_vomitjar_spawn', 'weapon_xm1014',
}

timer.Simple 0, ->
	table.insert(def_weapons, data.ClassName) for classname, data in pairs(list.Get('Weapon')) when data.ClassName
	table.insert(def, data.Class) for classname, data in pairs(list.Get('NPC')) when data.Class

	table.deduplicate(def)
	table.deduplicate(def_weapons)

DPP2.ClassnameAutocomplete = (args, margs, excludelist = empty) =>
	-- some of addons can register entities at runtime
	classnames = [data.ClassName for data in *weapons.GetList() when data.ClassName]
	table.append(classnames, [classname for classname in pairs(scripted_ents.GetList())])
	table.append(classnames, def)
	table.append(classnames, def_weapons)
	table.sort(classnames)
	table.deduplicate(classnames)
	return [string.format('%q', classname) for classname in *classnames] if args == ''
	args = args\lower()

	output = {}

	for classname in *classnames
		-- we proably got several entities which start with same name

		if classname\startsWith(args) and not table.qhasValue(excludelist, classname)
			table.insert(output, string.format('%q', classname))

	return output

DPP2.WeaponAutocomplete = (args, margs, excludelist = empty) =>
	-- some of addons can register entities at runtime
	classnames = [data.ClassName for data in *weapons.GetList() when data.ClassName]
	table.append(classnames, def_weapons)
	table.sort(classnames)
	table.deduplicate(classnames)
	return [string.format('%q', classname) for classname in *classnames] if args == ''
	args = args\lower()

	output = {}

	for classname in *classnames
		-- we proably got several entities which start with same name

		if classname\startsWith(args) and not table.qhasValue(excludelist, classname)
			table.insert(output, string.format('%q', classname))

	return output
