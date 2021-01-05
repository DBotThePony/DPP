
-- Copyright (C) 2018-2020 DBotThePony

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

gui.dpp2.access.status.contraption = 'Конструкция'
gui.dpp2.access.status.contraption_ext = 'Конструкция <%d>'
gui.dpp2.access.status.map = 'Создано картой'
gui.dpp2.access.status.world = 'Без владельца'
gui.dpp2.access.status.friend = 'Не является другом владельца'
gui.dpp2.access.status.invalident = 'Неверная сущность'
gui.dpp2.access.status.disabled = 'Защита отключена'
gui.dpp2.access.status.ownerdisabled = 'Защита для владельца отключена'
gui.dpp2.access.status.yoursettings = 'Ваши настройки'
gui.dpp2.access.status.toolgun_player = 'Невозможно использовать Инструмент на игроке'
gui.dpp2.access.status.model_blacklist = 'Модель в черном списке'
gui.dpp2.access.status.toolgun_mode_blocked = 'Использование этого Инструмента ограничено'
gui.dpp2.access.status.toolgun_mode_excluded = 'Использование этого Инструмента разрешено'
gui.dpp2.access.status.lock_self = 'Ваш собственный блок'
gui.dpp2.access.status.lock_other = 'Блок остальных'
gui.dpp2.access.status.no_surf = 'Анти-сёрф'

gui.dpp2.access.status.damage_allowed = 'Урон разрешён'

message.dpp2.owning.owned = 'Теперь вы являетесь владельцем этой сущности'
message.dpp2.owning.owned_contraption = 'Теперь вы являетесь владельцем этой конструкции'
message.dpp2.notice.upforgrabs = 'Сущности %s теперь доступны для забора!'
message.dpp2.notice.cleanup = 'Сущности %s были удалены.'
message.dpp2.warn.trap = 'Ваша сущность, возможно, застряла в другом игроке. Взаимодействие с сущностью снимет статус призрака!'
message.dpp2.warn.collisions = 'Ваша сущность, возможно, застряла в другой сущности. Взаимодействие с сущностью снимет статус призрака!'
message.dpp2.restriction.spawn = 'Сущность %q ограничена для вашей пользовательской группы'
message.dpp2.restriction.e2fn = 'DPP/2: Expression 2 функция %q ограничена для вашей пользовательской группы'

gui.dpp2.chosepnl.buttons.to_chosen = 'Выбрать >'
gui.dpp2.chosepnl.buttons.to_available = '< Убрать'
gui.dpp2.chosepnl.column.available = 'Доступно'
gui.dpp2.chosepnl.column.chosen = 'Выбрано'
gui.dpp2.chosepnl.add.add = 'Добавить'
gui.dpp2.chosepnl.add.entry = 'Добавить собственный вариант'
gui.dpp2.restriction.is_whitelist = 'Список групп работает как белый список'
gui.dpp2.restriction.edit_title = 'Редактирование ограничения %q'
gui.dpp2.restriction.edit_multi_title = 'Редактирование нескольких ограничений'

gui.dpp2.cvars.protection = 'Главный рубильник защиты'

gui.dpp2.cvars.autocleanup = 'Удалять сущности игроков по таймеру'
gui.dpp2.cvars.autocleanup_timer = 'Таймер удаления'
gui.dpp2.cvars.autofreeze = 'Замораживать физические сущности'
gui.dpp2.cvars.autoghost = 'Делать призраком вместо заморозки'
message.dpp2.notice.frozen = 'Сущности %s теперь заморожены!'

gui.dpp2.cvars.upforgrabs = 'Включить таймер для забора'
gui.dpp2.cvars.upforgrabs_timer = 'Время до забора'

gui.dpp2.cvars.no_tool_player = 'Запретить использовать Инструмент на игроках'
gui.dpp2.cvars.no_tool_player_admin = 'Запретить использовать Инструмент на игроках как администратор'

for {modeID, modeName} in *{{'physgun', 'Физпушка'}, {'toolgun', 'Инструмент'}, {'drive', 'Управление сущностями'}, {'damage', 'Урон'}, {'pickup', 'Подбор'}, {'use', 'Использование'}, {'vehicle', 'Транспортные средства'}, {'gravgun', 'Гравипушка'}}
	gui.dpp2.cvars[modeID .. '_protection'] = string.format('Включить модуль защиты %q', modeName)
	gui.dpp2.cvars[modeID .. '_touch_any'] = string.format('%s: Администраторы могут использовать все', modeName)
	gui.dpp2.cvars[modeID .. '_no_world'] = string.format('%s: Запретить игрокам использовать сущности без владельца', modeName)
	gui.dpp2.cvars[modeID .. '_no_world_admin'] = string.format('%s: Запретить администраторам использовать сущности без владельца', modeName)
	gui.dpp2.cvars[modeID .. '_no_map'] = string.format('%s: Запретить игрокам использовать сущности карты', modeName)
	gui.dpp2.cvars[modeID .. '_no_map_admin'] = string.format('%s: Запретить администраторам использовать сущности карты', modeName)

	gui.dpp2.cvars['el_' .. modeID .. '_enable'] = string.format('Включить список исключений для %q', modeName)

	gui.dpp2.cvars['bl_' .. modeID .. '_enable'] = string.format('Включить чёрный список для %q', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_whitelist'] = string.format('Чёрный список %q работает как белый список', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_admin_bypass'] = string.format('Чёрный список %q не распространяется на администраторов', modeName)

	gui.dpp2.cvars['rl_' .. modeID .. '_enable'] = string.format('Включить список ограничений для %q', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert'] = string.format('Инвентировать список ограничений для %q', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert_all'] = string.format('Полностью инвентировать список ограничений для %q', modeName)

	gui.dpp2.cvars['cl_' .. modeID .. '_protection'] = string.format('Включить модуль защиты %q для моих сущностей', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_other'] = string.format('%s: Запретить использовать сущности других игроков', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_world'] = string.format('%s: Запретить использовать сущности без владельца', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_map'] = string.format('%s: Запретить использовать сущности карты', modeName)
	gui.dpp2.cvars['cl_' .. modeID .. '_no_players'] = string.format('%s: Я не хочу действовать на игроков', modeName)
	gui.dpp2.buddystatus[modeID] = 'Товарищ в ' .. modeName

	gui.dpp2.toolmenu.restrictions[modeID] = 'Ограничения ' .. modeName
	gui.dpp2.toolmenu.blacklist[modeID] = 'Чёрный список ' .. modeName
	gui.dpp2.toolmenu.exclusions[modeID] = 'Исключения ' .. modeName
	gui.dpp2.toolmenu.names[modeID] = modeName

	gui.dpp2.property.lock_self[modeID] = 'Заблокировать использование ' .. modeName
	gui.dpp2.property.unlock_self[modeID] = 'Разрешить использование ' .. modeName
	gui.dpp2.property.lock_others[modeID] = gui.dpp2.property.lock_self[modeID]
	gui.dpp2.property.unlock_others[modeID] = gui.dpp2.property.unlock_self[modeID]

	command.dpp2.lock_self[modeID] = 'Использование #E в модуле ' .. modeName .. ' успешно заблокировано'
	command.dpp2.unlock_self[modeID] = 'Использование #E в модуле ' .. modeName .. ' успешно разблокировано'
	command.dpp2.lock_others[modeID] = 'Использование #E в модуле ' .. modeName .. ' для остальных успешно заблокировано'
	command.dpp2.unlock_others[modeID] = 'Использование #E в модуле ' .. modeName .. ' для остальных успешно разблокировано'

	command.dpp2.blacklist.added[modeID] = '#E добавил %s в чёрный список ' .. modeName
	command.dpp2.blacklist.removed[modeID] = '#E удалил %s из чёрного списка ' .. modeName

	command.dpp2.exclist.added[modeID] = '#E добавил %s из списка исключений ' .. modeName
	command.dpp2.exclist.removed[modeID] = '#E удалил %s из списка исключений ' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_blacklist'] = 'Добавить в чёрный список ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_blacklist'] = 'Удалить из чёрного списка ' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_exclist'] = 'Добавить в список исключений ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_exclist'] = 'Удалить из списка исключений' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_restrictions'] = 'Добавить в список ограничений ' .. modeName .. '...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_restrictions'] = 'Редактировать в списке ограничений ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_restrictions'] = 'Удалить из списка ограничений ' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_limits'] = 'Добавить в список лимитов ' .. modeName .. '...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_limits'] = 'Редактировать с списке лимитов ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_limits'] = 'Удалить из списка лимитов ' .. modeName

	gui.dpp2.disable_protection[modeID] = 'Отключить модуль защиты ' .. modeName

	command.dpp2.rlists.added[modeID] = '#E добавил %q в список ограничений ' .. modeName .. ' с флажком белого списка на %s'
	command.dpp2.rlists.added_ext[modeID] = '#E добавил %q в список ограничений ' .. modeName .. ' с группами %q и с флажком белого списка на %s'
	command.dpp2.rlists.updated[modeID] = '#E изменил %q в ' .. modeName .. ' с группами %q и с флажком белого списка на %s'
	command.dpp2.rlists.removed[modeID] = '#E удалил %q из списка ограничений ' .. modeName

	command.dpp2.enabled_for[modeID] = '#E включил модуль защиты ' .. modeName .. ' для #E'
	command.dpp2.disabled_for[modeID] = '#E отключил модуль защиты ' .. modeName .. ' для #E'
	command.dpp2.already_disabled_for[modeID] = 'Модуль защиты ' .. modeName .. ' для #E уже отключен!'
	command.dpp2.already_enabled_for[modeID] = 'Модуль защиты ' .. modeName .. ' для #E уже включен!'
	gui.dpp2.access.status['ownerdisabled_' .. modeID] = 'Защита ' .. modeName .. ' для владельца отключена'
	gui.dpp2.access.status[modeID .. '_exclusion'] = 'Сущность находится в списке исключений'

	gui.dpp2.sharing['share_' .. modeID] = 'Поделится в ' .. modeName

command.dpp2.rlists.added.model = '#E добавил %q в список ограничения моделей с флажком белого списка на %s'
command.dpp2.rlists.added_ext.model = '#E добавил %q в список ограничения моделей с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.updated.model = '#E изменил %q в списке ограничения моделей с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.removed.model = '#E удалил %q из списка ограничения моделей'

command.dpp2.rlists.added.e2fn = '#E добавил %q в список ограничений Expression 2 Function с флажком белого списка на %s'
command.dpp2.rlists.added_ext.e2fn = '#E добавил %q в список ограничений Expression 2 Function с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.updated.e2fn = '#E изменил %q в список ограничений Expression 2 Function с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.removed.e2fn = '#E удалил %q из списка ограничений Expression 2 Function'

gui.dpp2.cvars.rl_e2fn_enable = 'Включить список ограничений Expression 2'
gui.dpp2.cvars.rl_e2fn_invert = 'Список ограничений Expression 2 инвертирован'
gui.dpp2.cvars.rl_e2fn_invert_all = 'Список ограничений Expression 2 полностью инвертирован'

do
	modeID = 'model'
	gui.dpp2.menu['add_to_' .. modeID .. '_limits'] = 'Добавить в список лимитов моделей...'
	gui.dpp2.menu['edit_in_' .. modeID .. '_limits'] = 'Редактировать в списке лимитов моделей'
	gui.dpp2.menu['remove_from_' .. modeID .. '_limits'] = 'Удалить из списка лимитов моделей'

gui.dpp2.cvars.rl_enable = 'Включить списки ограничений'
gui.dpp2.cvars.bl_enable = 'Включить чёрные списки'
gui.dpp2.cvars.excl_enable = 'Включить списки исключений'

gui.dpp2.model_blacklist.window_title = 'Визуальный чёрный список моделей'
gui.dpp2.model_exclusions.window_title = 'Визуальный список моделей-исключений'
gui.dpp2.model_restrictions.window_title = 'Визуальный список ограниченных моделей'
gui.dpp2.model_limits.window_title = 'Визуальный список лимитов моделей'

gui.dpp2.access.status.model_exclusion = 'Модель в списке исключений'

for {modeID, modeName} in *{{'model', 'Модель'}, {'toolgun_mode', 'Инструмент'}, {'class_spawn', 'Сущность'}}
	gui.dpp2.cvars['el_' .. modeID .. '_enable'] = string.format('Включить список исключений %q', modeName)

	gui.dpp2.cvars['bl_' .. modeID .. '_enable'] = string.format('Включить чёрный список %q', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_whitelist'] = string.format('Чёрный список %q работает как белый список', modeName)
	gui.dpp2.cvars['bl_' .. modeID .. '_admin_bypass'] = string.format('Чёрный список %q не распространяется на администраторов', modeName)

	gui.dpp2.cvars['rl_' .. modeID .. '_enable'] = string.format('Включить список ограничений %q', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert'] = string.format('Список ограничений %q инвертирован', modeName)
	gui.dpp2.cvars['rl_' .. modeID .. '_invert_all'] = string.format('Список ограничений %q полностью инвертирован', modeName)

	gui.dpp2.menu['add_to_' .. modeID .. '_blacklist'] = 'Добавить в чёрный список ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_blacklist'] = 'Удалить из чёрного списка ' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_exclist'] = 'Добавить в список исключений ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_exclist'] = 'Удалить из списка исключений ' .. modeName

	gui.dpp2.menu['add_to_' .. modeID .. '_restrictions'] = 'Добавить в список ограничений ' .. modeName
	gui.dpp2.menu['edit_in_' .. modeID .. '_restrictions'] = 'Редактировать в списке ограничений ' .. modeName
	gui.dpp2.menu['remove_from_' .. modeID .. '_restrictions'] = 'Удалить из списка ограничений ' .. modeName

gui.dpp2.cvars.no_rope_world = 'Запретить создавать верёвки на мире'

gui.dpp2.cvars.log = 'Главный рубильник журнала'
gui.dpp2.cvars.log_echo = 'Выводить журнал в консоли сервера'
gui.dpp2.cvars.log_echo_clients = 'Выводить журнал в консоли администраторов'
gui.dpp2.cvars.log_spawns = 'Записывать в журнал создания сущностей'
gui.dpp2.cvars.log_toolgun = 'Записывать в журнал использование Инструмента'
gui.dpp2.cvars.log_tranfer = 'Записывать в журнал передачу сущностей'
gui.dpp2.cvars.log_write = 'Записывать журнал на диск'

gui.dpp2.cvars.physgun_undo = 'Включить историю отмены физпушки'
gui.dpp2.cvars.cl_physgun_undo = 'Включить историю отмены физпушки'
gui.dpp2.cvars.cl_physgun_undo_custom = 'Использовать отдельную историю для физпушки'

gui.dpp2.cvars.allow_damage_npc = 'Всегда разрешать наносить урон НИПам'
gui.dpp2.cvars.allow_damage_vehicle = 'Всегда разрешать наносить урон транспортным средствам'

gui.dpp2.cvars.cl_protection = 'Главный рубильник клиентской защиты'

gui.dpp2.cvars.cl_draw_contraption_aabb = 'Отрисовывать линии вокруг AABB конструкций (может сильно сказаться на производительности)'
gui.dpp2.cvars.cl_draw_owner = 'Отображать панель владельца'
gui.dpp2.cvars.cl_simple_owner = 'Простая панель владельца (стиль FPP)'
gui.dpp2.cvars.cl_entity_name = 'Отображать имена сущностей'
gui.dpp2.cvars.cl_entity_info = 'Отображать информацию сущностей'
gui.dpp2.cvars.cl_no_contraptions = 'Использовать упрощённую обработку конструкций. Может сильно улучшить производительность с большими конструкциями.'
gui.dpp2.cvars.cl_no_players = 'Не отображать панель владельца на других игроках'
gui.dpp2.cvars.cl_no_func = 'Не отображать панель владельца на сущностях дверей и func_'
gui.dpp2.cvars.cl_no_map = 'Не отображать панель владельца на сущностях во владении карты'
gui.dpp2.cvars.cl_no_world = 'Не отображать панель владельца на сущностях без владельца'
gui.dpp2.cvars.cl_ownership_in_vehicle = 'Отображать панель владельца будучи находясь в транспортном средстве'
gui.dpp2.cvars.cl_ownership_in_vehicle_always = 'Всегда отображать панель владельца будучи находясь в транспортном средстве'

gui.dpp2.cvars.cl_notify = 'Отображать уведомления на экране'
gui.dpp2.cvars.cl_notify_generic = 'Отображать общие уведомления на экране'
gui.dpp2.cvars.cl_notify_error = 'Отображать уведомления об ошибках на экране'
gui.dpp2.cvars.cl_notify_hint = 'Отображать подсказки на экране'
gui.dpp2.cvars.cl_notify_undo = 'Отображать уведомления об отмене на экране'
gui.dpp2.cvars.cl_notify_cleanup = 'Отображать уведомления об очистке на экране'
gui.dpp2.cvars.cl_notify_sound = 'Проигрывать звук на уведомлениях'
gui.dpp2.cvars.cl_notify_timemul = 'Множитель времени показа уведомлений'

gui.dpp2.cvars.cl_properties = 'Отображать DPP/2 в контекстном меню сущностей'
gui.dpp2.cvars.cl_properties_regular = 'Отображать общие свойства в контекстном меню сущностей'
gui.dpp2.cvars.cl_properties_admin = 'Отображать административные свойства в контекстном меню сущностей'
gui.dpp2.cvars.cl_properties_restrictions = 'Отображать ограничивающие свойства в контекстном меню сущностей'

gui.dpp2.cvars.draw_owner = 'Серверное переопределение: Отображать панель владельца'
gui.dpp2.cvars.simple_owner = 'Серверное переопределение: Простая панель владельца (стиль FPP)'
gui.dpp2.cvars.entity_name = 'Серверное переопределение: Отображать имена сущностей'
gui.dpp2.cvars.entity_info = 'Серверное переопределение: Отображать информацию сущностей'

gui.dpp2.cvars.apropkill = 'Анти пропкилл'
gui.dpp2.cvars.apropkill_damage = 'Предотвращать урон от давки'
gui.dpp2.cvars.apropkill_damage_nworld = 'Игнорировать давку от сущностей без владельца'
gui.dpp2.cvars.apropkill_damage_nveh = 'Игнорировать давку от транспортных средств'
gui.dpp2.cvars.apropkill_trap = 'Препятствовать захват игроков сущностями'
gui.dpp2.cvars.apropkill_push = 'Препятствовать толканию сущностями игроков'
gui.dpp2.cvars.apropkill_throw = 'Препятствовать киданию сущностей физпушкой'
gui.dpp2.cvars.apropkill_punt = 'Препятствовать киданию сущностей гравипушкой'
gui.dpp2.cvars.apropkill_surf = 'Препятствовать сёрфу на сущностях\n(требует "помощи" со стороны других модификаций,\nтаких как DSit)'

gui.dpp2.cvars.antispam = 'Рубильник антиспама'
gui.dpp2.cvars.antispam_ignore_admins = 'Антиспам игнорирует администрацию'
gui.dpp2.help.antispam_ignore_admins = 'Имейте ввиду, что игнорирование администрации\nможет негативно сказаться на настройке антиспама\nдля обычных игроков в следствие неполного тестирования настроек.'
gui.dpp2.cvars.antispam_unfreeze = 'Антиспам разморозки'
gui.dpp2.cvars.antispam_unfreeze_div = 'Множитель времени антиспама разморозки'
gui.dpp2.cvars.antispam_collisions = 'Препятствовать созданию сущности внутри другой сущности'
gui.dpp2.cvars.antispam_spam = 'Препятствовать спаму'
gui.dpp2.cvars.antispam_spam_threshold = 'Предел создания сущности как призрака при спаме'
gui.dpp2.cvars.antispam_spam_threshold2 = 'Предел удаления сущности при спаме'
gui.dpp2.cvars.antispam_spam_cooldown = 'Скорость сброса счётчика спама'
gui.dpp2.cvars.antispam_vol_aabb_div = 'Делитель размера AABB'
gui.dpp2.cvars.antispam_spam_vol = 'Антиспам на основе объема'
gui.dpp2.cvars.antispam_spam_aabb = 'Антиспам на основе размера AABB'
gui.dpp2.cvars.antispam_spam_vol_threshold = 'Лимит по объему спама перед созданием как призрак'
gui.dpp2.cvars.antispam_spam_vol_threshold2 = 'Лимит по объему спама перед удалением'
gui.dpp2.cvars.antispam_spam_vol_cooldown = 'Скорость сброса счётчика объема'

gui.dpp2.cvars.antispam_ghost_by_size = 'Создавать сущности как призрак при определенном объеме'
gui.dpp2.cvars.antispam_ghost_size = 'Предел объема'

gui.dpp2.cvars.antispam_ghost_aabb = 'Создавать сущности как призрак при определенном размере AABB'
gui.dpp2.cvars.antispam_ghost_aabb_size = 'Предел размера AABB'

gui.dpp2.cvars.antispam_block_by_size = 'Автоматически добавлять в чёрный список при определенном объеме'
gui.dpp2.cvars.antispam_block_size = 'Предел объема'

gui.dpp2.cvars.antispam_block_aabb = 'Автоматически добавлять в чёрный список при определенном размере AABB'
gui.dpp2.cvars.antispam_block_aabb_size = 'Предел размера AABB'

message.dpp2.antispam.hint_ghosted = '%d сущностей были созданы как призраки из-за спама'
message.dpp2.antispam.hint_removed = '%d сущностей были удалены из-за спама'
message.dpp2.antispam.hint_unfreeze_antispam = 'Антиспам разморозки. Попробуйте снова через #.2f секунд'
message.dpp2.antispam.hint_disallowed = 'Действие запрещено по причине спама'

message.dpp2.antispam.hint_ghosted_single = 'Сущность была создана как призрак из-за спама'
message.dpp2.antispam.hint_removed_single = 'Сущность была удалена из-за спама'

message.dpp2.antispam.hint_ghosted_big = '%d сущностей были созданы как призраки из-за их размера. Коснитесь их для убора статуса призрака!'
message.dpp2.antispam.hint_ghosted_big_single = 'Сущность была создана как призрак из-за их размера. Коснитесь  для убора статуса призрака!'

command.dpp2.generic.invalid_side = 'Эта команда не может быть выполнена в данном контексте.'
command.dpp2.generic.notarget = 'Неверная цель команды!'
command.dpp2.generic.no_bots = 'Эта команда не может работать с ботами'
command.dpp2.generic.noaccess = 'Вы не можете выполнять данную команду (причина: %s)'
command.dpp2.generic.noaccess_check = 'Вы не можете выполнять данную команду на данной цели (причина: %s)'
command.dpp2.generic.invalid_time = 'Вы обязаны указать срок блокировки'

command.dpp2.cleanup = '#E удалил все сущности #E'
command.dpp2.cleanup_plain = '#E cудалил все сущности %s<%s/%s>'
command.dpp2.cleardecals = '#E очистил декали'
command.dpp2.cleanupgibs = '#E удалил мусорные сущности. #d сущностей было удалено'
command.dpp2.cleanupnpcs = '#E удалил всех НИПов #E'
command.dpp2.cleanupnpcs_plain = '#E удалил всех НИПов %s<%s/%s>'
command.dpp2.cleanupallnpcs = '#E удалил всех НИПов во владении игроков'
command.dpp2.cleanupall = '#E удалил все сущности во владении игроков'
command.dpp2.cleanupvehicles = '#E удалил все транспортные средства #E'
command.dpp2.cleanupvehicles_plain = '#E удалил все транспортные средства %s<%s/%s>'
command.dpp2.cleanupallvehicles = '#E удалил все транспортные средства во владении игроков'
command.dpp2.freezephys = '#E заморозил все сущности #E'
command.dpp2.freezephysall = '#E заморозил все сущности во владении игроков'
command.dpp2.freezephyspanic = '#E заморозил все сущности'
command.dpp2.cleanupdisconnected = '#E удалил все сущности отключившихся игроков'

command.dpp2.ban = '#E запретил игроку #E создавать сущности на срок %s'
command.dpp2.indefinitely = 'Неопределённый срок'
command.dpp2.permanent_ban = '#E запретил игроку #E создавать сущности на неопределённый срок'
command.dpp2.already_banned = 'Цель уже имеет блокировку на создание сущностей на неопределённый срок'
command.dpp2.unban.not_banned = 'Цель не имеет блокировки на создание сущностей'
command.dpp2.unban.unbanned = '#E разрешил игроку #E создавать сущности'
command.dpp2.unban.do_unban = 'Запретить'

command.dpp2.hint.none = '<никто>'
command.dpp2.hint.player = '<игрок>'
command.dpp2.hint.share.not_own_contraption = '<у вас нет сущностей во владении в данной конструкции>'
command.dpp2.hint.share.nothing_shared = '<нет сущностей которыми вы поделились>'
command.dpp2.hint.share.nothing_to_share = '<нечем делиться>'
command.dpp2.hint.share.not_owned = '<не является владельцем>'

command.dpp2.transfer.none = 'У вас нет сущностей которые вы могли бы передать.'
command.dpp2.transfer.already_ply = 'Вы уже выставили #E как преемника на владение вашими сущностями!'
command.dpp2.transfer.none_ply = 'У вас уже нет преемника на владение сущностями!'

command.dpp2.transfered = '#E передал права на свои сущности игроку #E'
command.dpp2.transferfallback = 'Игрок #E успешно выставлен как преемник прав на ваши сущности'
command.dpp2.transferunfallback = 'Преемник успешно убран'

message.dpp2.transfer.as_fallback = '%s<%s> передал #d сущностей игроку #E как преемник'
message.dpp2.transfer.no_more_fallback = 'Ваш преемник отключился от сервера!'

command.dpp2.transferent.notarget = 'Указана неверная сущность'
command.dpp2.transfercontraption.notarget = 'Указана неверная конструкция'
command.dpp2.transferent.not_owner = 'Вы не являетесь владельцем данной сущности!'
command.dpp2.transfercontraption.not_owner = 'Вы не владеете ни одной сущностью в данной конструкции!'
command.dpp2.transferent.success = 'Успешно передал #E игроку #E'
command.dpp2.transfertoworldent.success = 'Успешно убрал владельца #E'
command.dpp2.transfercontraption.success = 'Успешно передал #d сущностей игроку #E'
command.dpp2.transfertoworld.success = 'Успешно убрал владельца у #d сущностей'

gui.dpp2.property.transferent = 'Передать права на данную сущность...'
gui.dpp2.property.transfertoworldent = 'Убрать владельца у данной сущности'
gui.dpp2.property.transfercontraption = 'Передалть права на данную конструкцию...'
gui.dpp2.property.transfertoworldcontraption = 'Убрать владельца у данной конструкции'

gui.dpp2.property.banning = 'DPP/2 бан...'

gui.dpp2.property.restrictions = 'Ограничения DPP/2'
gui.dpp2.property.lock_self.top = 'Запретить мне...'
gui.dpp2.property.unlock_self.top = 'Разрешить мне...'
gui.dpp2.property.lock_others.top = 'Запретить другим...'
gui.dpp2.property.unlock_others.top = 'Разрешить другим...'

message.dpp2.property.transferent.nolongervalid = 'Сущность более не является действительной'
message.dpp2.property.transferent.noplayer = 'Целевой игрок отключился от сервера'
message.dpp2.property.transfercontraption.nolongervalid = 'Конструкция более не является действительной'

message.dpp2.blacklist.model_blocked = 'Модель %s находится в чёрном списке'
message.dpp2.blacklist.model_restricted = 'Модель %s ограничена для вашей группы'
message.dpp2.blacklist.models_blocked = '#d сущностей были удалены из-за их нахождения в чёрном или ограничивающем списке'
message.dpp2.spawn.banned = 'Вам запрещено создавать сущности'
message.dpp2.spawn.banned_for = 'Вам запрещено создавать сущности в течение следующих %s'

command.dpp2.lists.arg_empty = 'Вы не предоставили аргумент'
command.dpp2.lists.group_empty = 'Вы не указали имя группы!'
command.dpp2.lists.limit_empty = 'Значение лимита неверно'
command.dpp2.lists.already_in = 'Целевой список уже имеет данный элемент!'
command.dpp2.lists.already_not = 'Целевой список не имеет данного элемента!'

command.dpp2.blacklist.added.model = '#E добавил %s в чёрный список моделей'
command.dpp2.blacklist.removed.model = '#E удалил %s из чёрного списка моделей'

command.dpp2.exclist.added.model = '#E добавил %s в список исключений моделей'
command.dpp2.exclist.removed.model = '#E удалил %s из списка исключений моделей'
command.dpp2.exclist.added.toolgun_mode = '#E добавил %s в список исключений инструментов'
command.dpp2.exclist.removed.toolgun_mode = '#E удалил %s из списка исключений инструментов'

message.dpp2.log.spawn.generic = '#E создал #E'
message.dpp2.log.spawn.tried_generic = '#E #C попытался #C создать #E'
message.dpp2.log.spawn.tried_plain = '#E #C попытался #C to создать %q'
message.dpp2.log.spawn.giveswep = '#E выдал себе #C%s'
message.dpp2.log.spawn.giveswep_valid = '#E выдал себе #E'
message.dpp2.log.spawn.prop = '#E создал #E [%s]'
message.dpp2.log.in_next = 'Журналирование продолжено в %s'

message.dpp2.log.transfer.world = '#E убрал владельца сущности #E'
message.dpp2.log.transfer.other = '#E передал права на сущность #E к игроку #E'

message.dpp2.log.toolgun.regular = '#E использовал инструмент %s на #E'
message.dpp2.log.toolgun.property = '#E использовал свойство %s на #E'
message.dpp2.log.toolgun.world = '#E использовал инструмент %s на мире'

command.dpp2.rlists.added.toolgun_mode = '#E добавил %q to в список ограничений инструментов и с флажком белого списка на %s'
command.dpp2.rlists.added_ext.toolgun_mode = '#E добавил %q в список ограничений инструментов с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.updated.toolgun_mode = '#E изменил %q в списке ограничений инструментов с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.removed.toolgun_mode = '#E удалил %q из списка ограничений инструментов'

command.dpp2.rlists.added.class_spawn = '#E добавил %q в список ограничений сущностей с флажком белого списка на %s'
command.dpp2.rlists.updated.class_spawn = '#E изменил %q в списке ограничений сущностей с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.added_ext.class_spawn = '#E добавил %q в список ограничений сущностей с группами %q и с флажком белого списка на %s'
command.dpp2.rlists.removed.class_spawn = '#E удалил %q из списка ограничений сущностей'

gui.dpp2.toolcategory.main = 'Основные настройки'
gui.dpp2.toolcategory.client = 'Клиентские настройки'
gui.dpp2.toolcategory.restriction = 'Списки ограничений'
gui.dpp2.toolcategory.blacklist = 'Чёрные списки'
gui.dpp2.toolcategory.player = 'Утилиты'
gui.dpp2.toolcategory.limits = 'Лимиты'
gui.dpp2.toolcategory.exclusions = 'Исключения'

gui.dpp2.toolmenu.select_tool = 'Выбрать данный инструмент'
gui.dpp2.toolmenu.select_tool2 = 'Достать данный инструмент'

gui.dpp2.toolmenu.playermode = 'Защита игроков'

gui.dpp2.toolmenu.client_protection = 'Настройки защиты'
gui.dpp2.toolmenu.client_settings = 'Общие настройки'
gui.dpp2.toolmenu.client_commands = 'Утилиты'
gui.dpp2.toolmenu.transfer = 'Передача владения'
gui.dpp2.toolmenu.transfer_fallback = 'Преемники'
gui.dpp2.toolmenu.primary = 'Основные настройки'
gui.dpp2.toolmenu.secondary = 'Вторичные настройки'
gui.dpp2.toolmenu.antipropkill = 'Анти-пропкилл'
gui.dpp2.toolmenu.antispam = 'Антиспам'
gui.dpp2.toolmenu.cleanup = 'Очистка'
gui.dpp2.toolmenu.utils = 'Утилиты'
gui.dpp2.toolmenu.logging = 'Журналирование'
gui.dpp2.toolmenu.restrictions.toolgun_mode = 'Ограничения инструментов (сущности)'
gui.dpp2.toolmenu.restrictions.class_spawn = 'Ограничения сущностей'
gui.dpp2.toolmenu.restrictions.model = 'Ограничения моделей'
gui.dpp2.toolmenu.restrictions.e2fn = 'Ограничения Expression 2'
gui.dpp2.toolmenu.exclusions.model = 'Исключения моделей'
gui.dpp2.toolmenu.exclusions.toolgun_mode = 'Ограничения режимов инструментов'

gui.dpp2.toolmenu.limits.sbox = 'Лимиты песочницы'
gui.dpp2.toolmenu.limits.entity = 'Лимиты сущностей'
gui.dpp2.toolmenu.limits.model = 'Лимиты моделей'

gui.dpp2.toolmenu.playerutil.clear = '%s: удалить сущности'
gui.dpp2.toolmenu.playerutil.freezephys = 'З'
gui.dpp2.toolmenu.playerutil.freezephys_tip = 'Заморозить сущности данного игрока'
gui.dpp2.toolmenu.playerutil.freezephysall = 'Заморозить сущности во владении игроков'
gui.dpp2.toolmenu.playerutil.freezephyspanic = 'Заморозить ВСЕ сущности'
gui.dpp2.toolmenu.playerutil.clear_all = 'Удалить сущности во владении игроков'
gui.dpp2.toolmenu.playerutil.clear_npcs = 'Удалить НИПов во владении игроков'
gui.dpp2.toolmenu.playerutil.clear_vehicles = 'Удалить транспортные средства во владении игроков'
gui.dpp2.toolmenu.playerutil.clear_disconnected = 'Удалить сущности отключившихся игроков'

gui.dpp2.toolmenu.blacklist.model = 'Чёрный список моделей'
gui.dpp2.toolmenu.util.cleardecals = 'Очистить декали'
gui.dpp2.toolmenu.util.cleanupgibs = 'Удалить мусор'

gui.dpp2.restriction_lists.view.classname = 'Имя класса'
gui.dpp2.restriction_lists.view.groups = 'Группы'
gui.dpp2.restriction_lists.view.iswhitelist = 'Белый список'
gui.dpp2.restriction_lists.add_new = 'Добавить...'

gui.dpp2.menus.add = 'Добавить новую запись...'
gui.dpp2.menus.query.title = 'Добавить новую запись'
gui.dpp2.menus.query.subtitle = 'Пожалуйста, введите имя класса нового (или существующего) ограничения'

gui.dpp2.menus.edit = 'Изменить...'
gui.dpp2.menus.remove = 'Удалить'
gui.dpp2.menus.remove2 = 'Подтвердить'
gui.dpp2.menus.copy_classname = 'Копировать имя класса'
gui.dpp2.menus.copy_groups = 'Копировать группы'
gui.dpp2.menus.copy_group = 'Копировать группу'
gui.dpp2.menus.copy_limit = 'Копировать лимит'

gui.dpp2.property.copymodel = 'Копировать модель'
gui.dpp2.property.copyangles = 'Копировать угол'
gui.dpp2.property.copyvector = 'Копировать позицию'
gui.dpp2.property.copyclassname = 'Копировать имя класса'

command.dpp2.setvar.none = 'Не указана консольная переменная'
command.dpp2.setvar.invalid = 'Консольная переменная не принадлежит DPP/2: %s'
command.dpp2.setvar.no_arg = 'Не указано новое значение'
command.dpp2.setvar.changed = '#E изменил значение переменной dpp2_%s'

gui.dpp2.sharing.window_title = 'Поделиться'
gui.dpp2.property.share = 'Поделиться...'
gui.dpp2.property.share_all = 'Поделиться полностью'
gui.dpp2.property.un_share_all = 'Более не делиться полностью'
gui.dpp2.property.share_contraption = 'Поделиться конструкцией...'
command.dpp2.sharing.no_target = 'Не указана цель для общего доступа'
command.dpp2.sharing.no_mode = 'Не указан режим для общего доступа'
command.dpp2.sharing.invalid_mode = 'Указан неверный режим для общего доступа'
command.dpp2.sharing.invalid_entity = 'Указана неверная сущность для общего доступа'
command.dpp2.sharing.invalid_contraption = 'Указана неверная конструкция для общего доступа'
command.dpp2.sharing.not_owner = 'Вы не можете открыть общий доступ к сущности, которой не владеете'
command.dpp2.sharing.already_shared = 'Сущность уже имеет общий доступ в данном режиме'
command.dpp2.sharing.shared = '#E теперь имеет общий доступ в режиме %s'
command.dpp2.sharing.shared_contraption = 'Все внутри конструкции %d теперь имеет общий доступ в режиме %s'
command.dpp2.sharing.already_not_shared = 'Сущность уже не имеет общего доступа в данном режиме'
command.dpp2.sharing.un_shared = '#E более не имеет общего доступа в режиме %s'
command.dpp2.sharing.un_shared_contraption = 'Все внутри конструкции %d более не имеет общего доступа в режиме %s'
command.dpp2.sharing.cooldown = 'Команда на перезарядке, попробуйте снова через #.2f секунд'

gui.dpp2.cvars.no_host_limits = 'Для хоста слушающего сервера или одиночной игры лимитов нет'
gui.dpp2.cvars.sbox_limits_enabled = 'Включить переопределения лимитов песочницы'
gui.dpp2.cvars.sbox_limits_inclusive = 'Список лимитов песочницы исключающий'
gui.dpp2.cvars.entity_limits_enabled = 'Включить лимиты на сущности'
gui.dpp2.cvars.entity_limits_inclusive = 'Список лимитов на сущности исключающий'
gui.dpp2.cvars.model_limits_enabled = 'Включить лимиты на модели'
gui.dpp2.cvars.model_limits_inclusive = 'Список лимитов на модели исключающий'
gui.dpp2.cvars.limits_lists_enabled = 'Включить списки лимитов'

command.dpp2.limit_lists.added.sbox = '#E добавил лимит песочницы %q для группы %s как #d'
command.dpp2.limit_lists.removed.sbox = '#E удалил лимит песочницы %q для группы %s'
command.dpp2.limit_lists.modified.sbox = '#E изменил лимит песочницы %q для группы %s на #d'

command.dpp2.limit_lists.added.entity = '#E добавил лимит сущностей %q для группы %s as #d'
command.dpp2.limit_lists.removed.entity = '#E удалил лимит сущностей %q для группы %s'
command.dpp2.limit_lists.modified.entity = '#E изменил лимит сущностей %q для группы %s на #d'

command.dpp2.limit_lists.added.model = '#E добавил лимит моделей %q для группы %s как #d'
command.dpp2.limit_lists.removed.model = '#E удалил лимит моделей %q для группы %s'
command.dpp2.limit_lists.modified.model = '#E изменил лимит моделей %q для группы %s на #d'

gui.dpp2.limit_lists.view.classname = 'Имя класса'
gui.dpp2.limit_lists.view.group = 'Группа'
gui.dpp2.limit_lists.view.limit = 'Лимит'
gui.dpp2.limit.edit_title = 'Редактирование лимитов для %s'

message.dpp2.limit.spawn = 'Вы достигнули лимита %s!'

message.dpp2.inspect.invalid_entity = 'Трассировка не нашала ни одной сущности'
message.dpp2.inspect.check_console = 'Проверьте свою консоль для результатов осмотра'

message.dpp2.inspect.clientside = '-- ВЫВОД КЛИЕНТА --'
message.dpp2.inspect.serverside = '-- ВЫВОД СЕРВЕРА --'
message.dpp2.inspect.footer = '--------------------------------------'

message.dpp2.inspect.result.class = 'Имя класса: %s'
message.dpp2.inspect.result.position = 'Позиция в мире: Vector(#f, #f, #f)'
message.dpp2.inspect.result.angles = 'Угол в мире: Angle(#f, #f, #f)'
message.dpp2.inspect.result.eye_angles = '"Глазной" угол в мире: Angle(#f, #f, #f)'
message.dpp2.inspect.result.table_size = 'Размер таблицы: #d'
message.dpp2.inspect.result.health = 'Здоровье: #d'
message.dpp2.inspect.result.max_health = 'Максимум здоровья: #d'

message.dpp2.inspect.result.owner_entity = 'Владелец: #E'
message.dpp2.inspect.result.owner_steamid = 'SteamID владельца: %s'
message.dpp2.inspect.result.owner_nickname = 'Nickname владельца: %s'
message.dpp2.inspect.result.owner_uniqueid = 'UniqueID владельца: %s'

message.dpp2.inspect.result.unowned = 'Сущность не имеет владельца'
message.dpp2.inspect.result.model = 'Модель: %s'
message.dpp2.inspect.result.skin = 'Скин: %s'
message.dpp2.inspect.result.bodygroup_count = 'Количество бадигрупов: #d'

gui.dpp2.property.arm_creator = 'Достать инструмент создания'

gui.dpp2.undo.physgun = 'Отменено действие физпушки'
gui.dpp2.undo.physgun_help = 'Для отмены действия физпушки используйте консольную команду dpp2_undo_physgun'
gui.dpp2.undo.physgun_nothing = 'Нечего отменять'

message.dpp2.autoblacklist.added_volume = 'Модель %q была автоматически добавилена в чёрный список на основе объема'
message.dpp2.autoblacklist.added_aabb = 'Модель %q была автоматически добавилена в чёрный список на основе размера AABB'

message.dpp2.import.dpp_friends = 'Импортировано #d записей из списка друзей DPP.'
message.dpp2.import.fpp_friends = 'Импортировано #d записей из списка друзей FPP.'
message.dpp2.import.no_fpp_table = 'FPP не содержит друзей'
message.dpp2.import.button_dpp_friends = 'Импортировать DPP друзей'
message.dpp2.import.button_fpp_friends = 'Импортировать FPP друзей'

message.dpp2.error.empty_constraint = 'Entity:GetConstrainedEntities() вернул неверные сущности?!'

gui.dpp2.toolmenu.playertransfer = 'Передать все к игроку %s'
gui.dpp2.toolmenu.playertransferfallback = 'Отметить игрока %s как преемника'

gui.dpp2.property.cleanup = 'Удалить сущности владельца'
gui.dpp2.property.cleanupnpcs = 'Удалить НИПов владельца'
gui.dpp2.property.cleanupvehicles = 'Удалить транспортные средства владельца'
