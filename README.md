**OpenRoblox**<br />
***Blockchain System***
<br /><br />

*How does it work?*
***
Everytime any player makes a transaction, it gets addeed to a queue of maximum 5 element each. Once the 5 element minimum requirment is reached the elements are transformed into a block. (see block-structure) Then the block gets added to a queue located in the datastore, and a messaging service :PublishAsync() is called to notify all the miners. Once the block gets mined, messaging service will broadcast the block informations, (see block-structure)
<br /><br />
*Kind-of Docs*<br />
***Block Structure***
***
The Block is the output class of a miner work. It containes the following keys.
* block_hash | sha256 of the transactions list
* block_elements | array of the transactions
* block_proof_of_work | miner output containing the final unique block indentifier that allows the block to be broadcasted to all of the clients.


