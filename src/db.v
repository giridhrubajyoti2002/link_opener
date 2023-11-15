module main

import os
import time

const header = '<shortcut> \t \t <url> \t \t <time_added>\n'

struct Db {
mut:
	links     []string
	links_map map[string]string
	filepath  string
}

fn (db Db) write_file(data string) bool {
	os.write_file(db.filepath, data) or {
		print_error(err.msg())
		return false
	}
	return true
}

fn (db Db) create_file() bool {
	os.mkdir_all(db.filepath.split('/')#[..-1].join('/')) or { print_error(err.msg()) }
	return db.write_file(header)
}

fn (mut db Db) get_links() map[string]string {
	if !os.exists(db.filepath) {
		db.create_file()
	}
	if db.links.len != unsafe { nil } {
		return db.links_map
	}
	db.links = []string{}
	db.links_map = map[string]string{}

	for line in os.read_lines(db.filepath) or { print_error(err.msg()) }#[1..] {
		db.links << line
	}
	for link in db.links {
		arr := link.split('\t')
		db.links_map[arr[0]] = arr[1]
	}
	return db.links_map
}

fn (mut db Db) add_link(shortcut string, url string) {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	_, is_int := db.validate_shortcut(shortcut) or {
		print_error(err.msg())
		return
	}
	if is_int {
		print_error('Invalid shortcut! Shortcut cannot start with a digit.')
		return
	}
	if shortcut in db.links_map {
		print_error('Shortcut already present! `${shortcut}` is already linked to `${db.links_map[shortcut]}`.')
		return
	}
	if url in db.links_map.values() {
		mut sc := ''
		for key, val in db.links_map {
			if val == url {
				sc = key
			}
		}
		print_error('Url already present! `${sc}` is already linked to `${url}`.')
		return
	}
	curr_time := time.now().str()
	if db.write_file('${os.read_file(db.filepath) or {
		print_error(err.msg())
		return
	}}${shortcut}\t${url}\t${curr_time}\n')
	{
		db.links << [shortcut, url, curr_time]
		db.links_map[shortcut] = url
		print_success('`${shortcut}` now linked to `${url}`.')
	}
}

fn (mut db Db) print_links() {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	print('<position>\t' + header)
	for idx, link in db.links {
		println('    ${idx + 1}\t\t${link}')
	}
}

fn (db Db) open_url(url string) {
	mut cmd := match os.user_os() {
		'windows' {
			'start'
		}
		'macos' {
			'open'
		}
		else {
			'xdg-open'
		}
	}
	res := os.execute_or_exit('${cmd} ${url}')
	if res.exit_code == 0 {
		println('`${url}` opened in default browser.')
	} else {
		print_error(res.output)
	}
}

fn (mut db Db) open_shortcut(shortcut string) {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	sc, is_int := db.validate_shortcut(shortcut) or {
		print_error(err.msg())
		return
	}
	if is_int && (sc.int() >= db.links.len || sc.int() < 0) {
		print_error('Invalid position! Position should be between 1 and ${db.links.len}.')
		return
	} else if !is_int && sc !in db.links_map {
		print_error('Shortcut not found! You have not saved any link with `${sc}` shortcut.')
		return
	}
	if is_int {
		db.open_url(db.links[sc.int()].split('\t')[1])
	} else {
		db.open_url(db.links_map[sc.str()])
	}
}

fn (mut db Db) validate_shortcut(shortcut string) !(string, bool) {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	// if shortcut is not an int nor a string, invalid shortcut.
	if shortcut[0].is_digit() && shortcut.runes().filter(!u8(it).is_digit()).len > 0 {
		return error('Invalid shortcut! Shortcut cannot start with a digit.')
	}
	if shortcut.int() != 0 || shortcut[0] == `0` {
		index := shortcut.int() - 1
		return index.str(), true
	}
	return shortcut, false
}

fn (mut db Db) move_link(shortcut string, position string) {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	_, is_int := db.validate_shortcut(shortcut) or {
		print_error(err.msg())
		return
	}
	if is_int {
		print_error('Invalid shortcut! Shortcut cannot start with a digit.')
		return
	} else if shortcut !in db.links_map {
		print_error('Shortcut not found! You have not saved any link with `${shortcut}` shortcut.')
		return
	} else if position.int() == 0 || position.runes().filter(!u8(it).is_digit()).len > 0
		|| position.int() - 1 >= db.links.len {
		print_error('Position should be a number between 1 and ${db.links.len} inclusive.')
		return
	}
	new_idx := position.int() - 1
	mut curr_idx := -1
	for i, link in db.links {
		if link.split('\t')[0] == shortcut {
			curr_idx = i
			break
		}
	}
	if new_idx == curr_idx {
		print_error('`${shortcut}` is already in position ${curr_idx + 1}.')
		return
	} else if new_idx < curr_idx {
		db.links.insert(new_idx, db.links[curr_idx])
		db.links.delete(curr_idx + 1)
	} else {
		db.links.insert(new_idx + 1, db.links[curr_idx])
		db.links.delete(curr_idx)
	}
	if db.write_file(header + db.links.join_lines() + '\n') {
		print_success('`${shortcut}` moved to position ${new_idx + 1}.')
	} else {
		print_error('Something wrong happened! `${shortcut}` cannot be moved.')
	}
}

fn (mut db Db) remove_link(shortcut string) {
	if db.links.len == unsafe { nil } {
		db.get_links()
	}
	_, is_int := db.validate_shortcut(shortcut) or {
		print_error(err.msg())
		return
	}
	if is_int {
		print_error('Invalid shortcut! Shortcut cannot start with a digit.')
		return
	} else if shortcut !in db.links_map {
		print_error('Shortcut not found! You have not saved any link with `${shortcut}` shortcut.')
		return
	}
	url := db.links_map[shortcut]
	db.links_map.delete(shortcut)
	mut idx := -1
	for i, link in db.links {
		if link.split('\t')[0] == shortcut {
			idx = i
			break
		}
	}
	db.links.delete(idx)
	if db.write_file(header + db.links.join_lines() + '\n') {
		print_success('`${shortcut}` linked to `${url}` removed successfully.')
	} else {
		print_error('Something wrong happened! `${shortcut}` cannot be removed.')
	}
}
