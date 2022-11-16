# https://github.com/rust-onig/rust-onig/blob/68393b487c679c789ee8a762e77f568e75a3128a/appveyor_rust_install.ps1
iwr https://win.rustup.rs -outfile "$env:temp\rustup-init.exe"
if(!(gcm rustup)) {
	& "$env:temp\rustup-init.exe" -y --default-host=x86_64-pc-windows-msvc 2>&1
	update-EnvVar
	rustc -vV
	cargo -vV
	# rustup -vV
	return
}

rustup update
