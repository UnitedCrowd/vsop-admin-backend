function checkNetwork() {
    if (!web3.isConnected()) {

        alert("Please connect to Metamask.");
        return -1;
    }

    // check network
    var networkID = web3.version.network;
    var networkName = "Kovan Test Network";	// change this in the future

    if (networkID !== "42")
    {
        alert("Please Switch to the " + networkName);
        return -1;
    }
    return 1;
}

function totalSupply() {
    if (checkNetwork() == -1) {
        return;
    }
    contractInstance.totalSupply(function (error, result) {
        if (!error) {
            var total_pool_option = result / Math.pow(10, 18);
            $('#total_pool_option').text(total_pool_option);
            $('#total_pool_option_tc').text(total_pool_option);
            //alert(result/Math.pow(10,18));
        } else {
            alert(error);
        }
    });
    return;
}

function getTotalEmployees() {
    if (checkNetwork() == -1) {
        return;
    }
    contractInstance.getTotalEmployees(function (error, result) {
        if (!error) {
            //alert(result);
            $('#emp_in_esop').text(result)
        } else {
            alert(error);
        }
    });
    return;
}

function getAvlblTokens() {
    if (checkNetwork() == -1) {
        return;
    }
    contractInstance.getAvlblTokens(function (error, result) {
        if (!error) {
            var remain_pool_options = result / Math.pow(10, 18);
            $('#remain_pool_options').text(remain_pool_options);
            //alert(result/Math.pow(10,18));
        } else {
            alert(error);
        }
    });
    return;
}

function getTotalBonusIssued() {
    if (checkNetwork() == -1) {
        return;
    }
    contractInstance.getTotalBonusIssued(function (error, result) {
        if (!error) {
            var extra_option_issued = result / Math.pow(10, 18);
            $('#extra_option_issued').text(extra_option_issued);
            //alert(result/Math.pow(10,18));
        } else {
            alert(error);
        }
    });
    return;
}

function getRemPercentage() {
    if (checkNetwork() == -1) {
        return;
    }
    contractInstance.totalSupply(function (error, _denominator) {
        if (!error) {
            contractInstance.getAvlblTokens(function (error, _numerator)
            {
                if (!error)
                {
                    var num = _numerator / Math.pow(10, 18);
                    var den = _denominator / Math.pow(10, 18);
                    var new_employee_pool = String((num * 100) / den) + "%";
                    $('#new_employee_pool').text(new_employee_pool);
                    //alert(String((num*100)/den)+"%");
                } else {
                    alert(error);
                }
            });
        } else {
            alert(error);
        }
    });
    return;
}

function getEmployeeSpecs(employeeAddress,callback) {
    if (checkNetwork() == -1) {
        return;
    }

    var vestedAmt = 0;
    contractInstance.getVestedAmount(employeeAddress, function (error, result) {
        if (!error) {
            //alert(result/Math.pow(10, 18));
            //vestedAmt = String(result);
            vestedAmt=result;
        }
    });

    contractInstance.getEmployeeSpecs(employeeAddress, function (error, result) {
        if (!error) {
            console.log("Issue Date: " + convert(String(result[0])));
            console.log("Cliff Date: " + convert(String(result[1])));
            console.log("Duration in seconds: " + String(result[2]));
            console.log("Tokens vested: " + vestedAmt);
            console.log("Tokens released: " + String(result[3]));
            console.log("Fully vested amount: " + String(result[4]));
            console.log("Bonus Issued: " + String(result[5]));
            console.log("Is Revokable: " + String(result[6]));
            console.log("Revoked: " + String(result[7]));
            callback(result,vestedAmt)
            /*return result;
            var issued_options=result[4]+result[5];
            
            */

        } else {
            alert(error);
            
        }
    });
    return;
}

function convert(ts) {
    var unixtimestamp = parseInt(ts);
    var months_arr = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    var date = new Date(unixtimestamp * 1000);
    var year = date.getFullYear();
    var month = months_arr[date.getMonth()];
    var day = date.getDate();
    var hours = date.getHours();
    var minutes = "0" + date.getMinutes();
    var seconds = "0" + date.getSeconds();
    var convdataTime = month + '-' + day + '-' + year + ' ' + hours + ':' + minutes.substr(-2) + ':' + seconds.substr(-2);
    return convdataTime;
}

function getRootAddress()
{
    $('#root_of_trust').text(ROTAddress);
    return ROTAddress;
}

function getContractAddress()
{
    $('#esop_contract').text(contractAddress);
    return contractAddress;
}
