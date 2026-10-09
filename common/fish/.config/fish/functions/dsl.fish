function dsl
	ds9 $argv -lock frame wcs -lock scale yes -lock colorbar yes -lock slice image -log -cmap Heat -match frame wcs
end