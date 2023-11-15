module main

import os
import flag
import maps

const version = '0.0.1'

const docs = 'https://github.com/giridhrubajyoti2002'

const ls = 'ls'

const reserved_keys = [ ls, 'help', 'q', 'quit', 'exit', '<shortcut>']

fn main() {
	mut fp := flag.new_flag_parser(os.args)

	fp.application('link_opener')
	fp.version(version)
	fp.description('')
	fp.skip_executable()

	mut flags := map[string]string{}

	flags['a'] = fp.string('add', `a`, '', 'webpage link to visit')
	flags['s'] = fp.string('shortcut', `s`, '', 'webpage link to visit')
	flags['r'] = fp.string('remove', `r`, '', 'webpage link to visit')
	flags['m'] = fp.string('move', `m`, '', 'webpage link to visit')
	flags['p'] = fp.string('position', `p`, '', 'webpage link to visit')
	flags['o'] = fp.string('open', `o`, '', 'webpage link to visit')

	fp.finalize() or {
		println(err)
		return
	}

	mut db := Db{
		// TODO
		filepath: match os.user_os() {
			'windows' {
				'C://Program Files/links.txt'
			}
			else {
				os.getwd().split('/')[0..3].join('/') + '/.config/link_opener/links.txt'
			}
		}
	}

	if os.args.len == 1 {
		recur(mut db)
	} else {
		pars_flags(os.args[1..]) or {
			print_error(err.msg())
			return
		}
		error_msg := 'Invalid flag combinations! Please visit `${docs}\` for more information.'
		flags = maps.filter[string, string](flags, fn (_ string, val string) bool {
			return val != ''
		})
		match flags.len {
			0 {
				if ls in os.args[1..] {
					db.print_links()
				} else {
					for shortcut in os.args[1..] {
						db.open_shortcut(shortcut)
					}
				}
			}
			1 {
				if 'r' in flags {
					db.remove_link(flags['r'])
				} else if 'o' in flags {
					db.open_shortcut(flags['o'])
				} else {
					print_error(error_msg)
				}
			}
			2 {
				if 'a' in flags && 's' in flags {
					if flags['s'] in reserved_keys {
						print_error('`${flags['s']}` is a reserved keyword. Please use another shortcut.')
						return
					}
					db.add_link(flags['s'], format_url(flags['a']))
				} else if 'm' in flags && 'p' in flags {
					db.move_link(flags['m'], flags['p'])
				} else {
					print_error(error_msg)
				}
			}
			else {
				print_error(error_msg)
			}
		}
	}
}

fn recur(mut db Db) {
	println('Type `help` for more information.')
	for {
		arg := os.input('>>> ')
		if arg in ['q', 'quit', 'exit'] {
			break
		}
		match arg {
			'help' {
				println('Type `q` or `quit` or `exit` to exit.\nPlease visit `$docs` for more information.')
			}
			ls {
				db.print_links()
			}
			else {
				db.open_shortcut(arg)
			}
		}
	}
}

fn pars_flags(args []string) ! {
	error_msg := 'Invalid flag options! Please visit for `${docs}` more information.'
	if args[0].starts_with('-') {
		if args.len % 2 != 0 {
			return error(error_msg)
		}
		for i := 0; i < args.len; i += 2 {
			if !args[i].starts_with('-') || args[i + 1].starts_with('-') {
				return error(error_msg)
			}
		}
	} else {
		for arg in args {
			if arg.starts_with('-') {
				return error(error_msg)
			}
		}
	}
}
