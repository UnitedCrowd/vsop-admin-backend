var logout_interval;
window.addEventListener('load', async () => {
    if (window.ethereum) {
        window.web3 = new Web3(ethereum);
        try {
            await ethereum.enable();

            console.log("[+] Connected to MetaMask");

            window.web3.eth.getAccounts(function (err, accounts) {
               
                if (err != null) {
                    alert("An error occurred: " + err);
                    $('#left_menus').hide();
                    $('#secure_area').hide();
                    $('#no_secure_area').show();
                } else if (accounts.length == 0) {
                    alert("User is not logged in to MetaMask");
                    $('#left_menus').hide();
                    $('#secure_area').hide();
                    $('#no_secure_area').show();
                } else {
                    //alert("User is logged in to MetaMask");
                    $('#left_menus').show();
                    $('#secure_area').show();
                    $('#no_secure_area').hide();
                }
            });

        } catch (error) {
            alert("Can't connect to network without permission!");
        }
    } else if (window.web3) {
        
        window.web3 = new Web3(web3.currentProvider);
    } else {
        alert("Non-Ethereum browser detected. You should consider trying MetaMask!");
    }
    
     logout_interval=setInterval(function(){
         
        window.web3.eth.getAccounts(function (err, accounts) {
               
                if (err != null) {
                    alert("An error occurred: " + err);
                    $('#left_menus').hide();
                    $('#secure_area').hide();
                    $('#no_secure_area').show();
                } else if (accounts.length == 0) {
                    alert("User is not logged in to MetaMask");
                    
                    $('#left_menus').hide();
                    $('#secure_area').hide();
                    $('#no_secure_area').show();
                    destroy_interval();
                    window.location.reload();
                } else {
                    //alert("User is logged in to MetaMask");
                    
                    $('#left_menus').show();
                    $('#secure_area').show();
                    $('#no_secure_area').hide();
                }
            });
    },3000);
    
});

function destroy_interval(){
    clearInterval(logout_interval);

}