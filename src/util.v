module main

fn format_url(urll string) string {
	mut url := urll
	if !url.starts_with('file:///') && !url.starts_with('https://') {
		if url.starts_with('/') {
			for {
				if url[0] == '/'.u8() {
					url = url[1..]
				} else {
					break
				}
			}
			url = 'file:///${url}'
		} else {
			if url.starts_with('ww') {
				url = url.split('.')[1..].join('.')
			}
			url = 'https://${url}'
		}
	}
	return url
}

fn print_error(msg string) {
	println('Error: ${msg}')
}
fn print_success(msg string) {
	println('Success: ${msg}')
}

