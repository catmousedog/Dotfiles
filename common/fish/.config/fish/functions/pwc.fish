function pwc --description 'Copy the current directory to the clipboard'
	pwd | string collect | wl-copy
end
