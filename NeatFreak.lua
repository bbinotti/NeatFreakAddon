FLAG = false
MOVEFLAG = true
DONE = false
BANK = false

function NeatFreak()
	print("NeatFreak loaded")
end

--obtain block of selected items
function blockSelect(bagId, slotId)
	if not FLAG then
		--To implement: Start always from min(slotEnd, slotStart)
		blockStartBag = bagId
		blockStartSlot = slotId
		FLAG = not FLAG
		itemType, itemData = GetCursorInfo()
		print("Starts: ", blockStartBag, blockStartSlot)
		--set item back to its slot
		PickupContainerItem(blockStartBag,blockStartSlot)
	else
		blockEndBag = bagId
		blockEndSlot = slotId
		FLAG = not FLAG
		MOVEFLAG = false
		print("Ends: ", blockEndBag, blockEndSlot)
		--drop last selection
		PickupContainerItem(blockEndBag,blockEndSlot)
		--pick up first selection
		PickupContainerItem(blockStartBag,blockStartSlot)
	end	
end	

--move the selected block to the desired location
function moveMult(containerId)
	if MOVEFLAG or DONE then
		return
	end
	print(containerId);
	targetBag, targetSlot = findItemSlot()
	bag = blockStartBag; slot = blockStartSlot;
	while true do
		--go to next item in block
		slot = slot + 1
		targetSlot = targetSlot + 1
		--if past the last slot of the bag, go to first slot of next bag
		if slot  == GetContainerNumSlots(bag)+1  then
			bag = bag + 1
			slot = 1
		end
		if targetSlot == GetContainerNumSlots(targetBag)+1 then
			targetBag = targetBag + 1
			targetSlot = 1
		end
		print("(", bag, ",", slot, "):(", targetBag, ",", targetSlot, ")" )
		PickupContainerItem(bag, slot)
		PickupContainerItem(targetBag, targetSlot)
		if bag == blockEndBag and slot == blockEndSlot then
			DONE = true
			break
		end
	end
end

function findItemSlot()
	--if CursorHasItem then
		--itemType, itemData = GetCursorInfo()
		--Find bag and slot number of selected item (uses first item match seen)
		if BANK then
			tempStart = -1
			tempEnd = NUM_BAG_SLOTS + NUM_BANKBAGSLOTS
		else
			tempStart = 0
			tempEnd  = NUM_BAG_SLOTS
		end
		print(tempStart, ",", tempEnd)
		for bag = tempStart,tempEnd do
			for slot = 1,GetContainerNumSlots(bag) do
				if GetContainerItemID(bag,slot) == itemData then
					--print(bag, slot)
					return bag, slot
				end
			end
		end	
	--end
end
