// beneficiary: address of receiver
// fullyVestedAmount: total amount to receive at the end
// startDate: start date in epoch. 0 indicates start "now"
// cliffSec: duration of cliff
// durationSec: duration
// isRevokable: is it isRevokable(boolean)
function grantVestedTokens(beneficiary, fullyVestedAmount, startDate, cliffSec, durationSec, isRevokable)
{
	if(!web3.isConnected()) {

	  
	  $.toast({
		heading: 'Error',
		text: "Please connect to Metamask.",
		position: 'top-right',
		loaderBg: '#ff6849',
		icon: 'error',
		hideAfter: 10000

	});
	return;
	}

	// check network
	var networkID = web3.version.network;	// change this in the future
	var networkName = "Kovan Test Network";	// change this in the future

	if(networkID !== "42")
	{
		
		$.toast({
			heading: 'Error',
			text: "Please Switch to the " + networkName,
			position: 'top-right',
			loaderBg: '#ff6849',
			icon: 'error',
			hideAfter: 10000
	
		});
		return;
	}

	crowdsaleInstance.grantVestedTokens.estimateGas(beneficiary, fullyVestedAmount, startDate, cliffSec, durationSec, isRevokable, function(error, result) {
		if (!error)
		{
			crowdsaleInstance.grantVestedTokens(beneficiary, fullyVestedAmount, startDate, cliffSec, durationSec, isRevokable, function(error, result)
			{
				if (!error)
				{
					// Transaction submitted Successfully
					
					$.toast({
						heading: 'Success',
						text: "This is the tx hash: " + result,
						position: 'top-right',
						loaderBg: '#ff6849',
						icon: 'success',
						hideAfter: 10000
				
					});
					return;
					// can open https://kovan.etherscan.io/tx/<result> in a new tab
				}
				else
				{
					if (error.message.indexOf("User denied") != -1)
					{
						
						$.toast({
							heading: 'Error',
							text: "You rejected the transaction on Metamask!",
							position: 'top-right',
							loaderBg: '#ff6849',
							icon: 'error',
							hideAfter: 10000
					
						});
						return;
					}
					else
					{
						// some unkonwn error
						
						$.toast({
							heading: 'Error',
							text: error,
							position: 'top-right',
							loaderBg: '#ff6849',
							icon: 'error',
							hideAfter: 10000
					
						});
						return;
					}
				}
			});
		}
		else
		{
			// transaction will fail! So dont execute
			
			$.toast({
				heading: 'Error',
				text: "This function cannot be run at this time.",
				position: 'top-right',
				loaderBg: '#ff6849',
				icon: 'error',
				hideAfter: 10000
		
			});
			return;
		}
	});

	return;
}
