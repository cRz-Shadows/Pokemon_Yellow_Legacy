CheckBadOffset::
	; in some cases we can end up near the end of the list with less than 3 entries showing like after depositing an item or pokemon
	; in this case we change the offset to avoid issues
	ld a, [wListCount] ; number of items in list, minus CANCEL (same value as max index value possible)
	cp 2
	ret c ; if less than 2 entries, no need to check
	; wListCount still loaded
	ld b, a ; wListCount in b
	ld a, [wListScrollOffset]
	and a
	ret z ; if scroll offset is 0, no need to check
	ld c, a
	ld a, b
	sub c
	cp 1
	ret nz
	ld hl, wListScrollOffset
	dec [hl] ; decs once because it is assumed only 1 item can be removed from the list at a time
	ret
