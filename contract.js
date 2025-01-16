var web3js;
var web3socket;
var accountcreated = false;
     App={
         web3provider : null,
         contract : {},
         account:'0x0',
         subscriber:null,
         isAdmin:false,
         websocketprovider:null,
         init:async function(){
             return await App.initweb3();
         },
         afterRender:async function(){
            
         },
         initweb3:async function(){
             if(typeof web3 !=='undefined'){
                 App.web3provider = window.ethereum;
                 web3js=new Web3(App.web3provider);
                 
             }
             else{
                 App.web3provider= Web3.providers.HttpProvider('http://localhost:7545');
                 web3js = new Web3(App.web3provider);
             }
             
             return await App.initContract();
         },
         initContract:async function(){
             fetch("./build/contracts/Daobuilder.json?v=6")
                 .then((res=>res.json()))
                 .then(async function(data) {
                     var myContractABI = data;
                     App.contract = new web3js.eth.Contract(myContractABI.abi, "0x759e95d94a40Eab114003e806C5A9Eb7D32aE962");
                     // App.websocketprovider = new Web3(new Web3.providers.WebsocketProvider('ws://localhost:7545'));
                     // let options = { address: '0x288F9EFfaa1f25032ADC508D9dfe52800eB65a3F'};
                     // subscribe = await App.websocketprovider.eth.subscribe('logs', options, (err, res) => {});
                     // subscribe.on("data", (txHash) => {
                     //     setTimeout(async () => {
                     //     try {
                     //         console.log(txHash);
                     //         let tx = await App.web3provider.getTransaction(txHash);
                     //         console.log(tx)
                     //     } catch (err) {
                     //         console.error(err);
                     //     }
                     //     });
                     // });
                     await App.getAccount();
                 })
                 .catch((error) =>console.error("Unable to fetch data:", error));
         },
         getAccount: async function(){
            
             var accountInterval = setInterval(function() {
                 web3js.eth.getAccounts().then(async function(accounts){
                         if(App.account!==accounts[0]){
                             $(document).find("#setadmins").hide();
                             $(document).find("#admins").html("Loading....");
                             $(document).find("#setVoters").hide();
                             $(document).find("#voters").html("Loading....");
                             $(document).find("#createvoting").hide();
                            //  $(document).find("#createvoting .holder").html("Loading");
                             $(document).find("#myvotings").hide();
                             $(document).find("#myvotings .holder").html("Loading");
                            //  $(document).find("#activevotings").hide();
                            //  $(document).find("#activevotings .holder").html("Loading");
                                 App.account = accounts[0];
                                 App.render();   
                         }                     
                 });
             },100);
             
         },
         render: async function() {
             
                             // App.contract.events.MyWholeFuckingData({ filter: { owner: App.account } })
                             // .on("data", function(event) {
                             //     accountcreated=true;
                             //     $('#withdrawamount').show();
                             //     $('#howmuchdraw').attr("max",Number(event.returnValues.balance)* 10**-18);
                             //     $('#bankbalnace').text("balance: "+Number(event.returnValues.balance)* 10**-18);
                             //     $('#card').text("cardnumber: "+event.returnValues.CardNumber);
                             //     $('#cvvtwo').text("cvv2: "+event.returnValues.CVV2);
                             //     $('#expdata').text("exp dat: "+event.returnValues.year+"-"+event.returnValues.year);
                             // });
                             App.contract.events.OwnershipTransferred()
                             .on("data",function(event){
                                     alert("Contract Admin Changed");
                                     location.reload();
                             });
                             App.contract.events.NewAdminAdded()
                             .on("data",async function(event){
                                     alert("New Voting admin added");
                                     await App.getAdminsList();
                             });
                             App.contract.events.VotingDataChanged()
                             .on("data",async function(event){
                                     alert(event.returnValues.msg);
                                     await App.getMyVotingData(event.returnValues.votingIndex);
                             });
                             App.contract.events.VotingOptionChanged()
                             .on("data",async function(event){
                                     alert(event.returnValues.msg);
                                     await App.getVotingOptions();
                             });
                             App.contract.events.VoterAdded()
                             .on('data',async function(event){
                                await App.getVoterByAddress(event.returnValues.voter);
                             });

                             App.contract.events.VoterEnabled()
                             .on('data',async function(event){
                                await App.getVoterByAddress(event.returnValues.voter);
                             });
                             App.contract.events.VoterDisabled()
                             .on('data',async function(event){
                                await App.getVoterByAddress(event.returnValues.voter);
                             });
                             App.contract.events.VoterPowerDecreased()
                             .on('data',async function(event){
                                await App.getVoterByAddress(event.returnValues.voter);
                             });
                             App.contract.events.VoterPowerIncreased()
                             .on('data',async function(event){
                                await App.getVoterByAddress(event.returnValues.voter);
                             });
                             $('#loginbox').text("address: "+App.account);
                            //  $(document).find("#activevotings").show();
                             await App.afterRender();
            
             
         },
         trasferOwnerShip:async function(){
             App.contract.methods.transferOwnership($(document).find('#newowner').val()).send({from:App.account});
         },
         addnewAdmin:async function(){
             App.contract.methods.addVotingAdmin($(document).find('#newadmin').val()).send({from:App.account});
         },
         RemoveAdmin:async function(id){
             await App.contract.methods.removeVotingAdmin(id).send({from:App.account}).then(async function(data){
                 await App.getAdminsList();
             });
         },
         getAdminsList: async function(){
             await App.contract.methods.lastVotingAdminId().call().then(async function(result){
                 $(document).find('#admins').html("");
                                 for(i=1;i<=parseInt(result);i++){
                                     await App.getAdminById(i).then(function(data){
                                         // console.log(data);
                                         let adminstatus = "<span style='color:green'>ACTIVE</span>";
                                         if(!data.enabled){
                                             adminstatus = "<span style='color:red'>INACTIVE</span>";
                                         }
                                         
                                         $(document).find('#admins').append(
                                             "<div id='adminholder"+data.admin+"'>Address: "+data.admin+ 
                                                 adminstatus+
                                                 "<button id='removeadmin' adminid='"+data.admin+"'>Remove Admin</buttn></div>"
                                         );
                                     });
                                 }
                 });
         },
         getAdminById:async function(id){
             return App.contract.methods.votingAdmins(id).call();
         },
         NewVoting:async function(){

             await App.contract.methods.addVoting(
                 Date.parse($(document).find('#votingStart').val()),
                 Date.parse($(document).find('#votingEnd').val()),
                 $(document).find('#votingTitle').val(),
                 $(document).find('#votingDescription').val()
             ).send({from:App.account});
         },
         changeStartDate:async function(id){
             await App.contract.methods.changeVotingStartDate(
                 id,
                 Date.parse($(document).find('#startdateofvoting'+id).val())
             ).send({from:App.account});
         },
         changeEndDate:async function(id){
             await App.contract.methods.changeVotingEndDate(
                 id,
                 Date.parse($(document).find('#enddateofvoting'+id).val())
             ).send({from:App.account});
         },
         changeTitle:async function(id){
             await App.contract.methods.changeVotingTitle(
                 id,
                 $(document).find('#titleofvoting'+id).val()
             ).send({from:App.account});
         },
         changeDescription:async function(id){
             await App.contract.methods.changeVotingDescription(
                 id,
                 $(document).find('#descriptionsofvoting'+id).val()
             ).send({from:App.account});
         },
         stopvoting: async function(id){
             await App.contract.methods.setVotingEnded(
                 id
             ).send({from:App.account});
         },
         startvoting:async function(id){
             if(App.isAdmin){
                 await App.contract.methods.setVotingActive(
                     id
                 ).send({from:App.account});
             }
         },
         getMyVotingData:async function(id){
             await App.contract.methods.votings(id).call().then(async function(data){
                 // console.table(data);
                 var owneroptions = "<button class='StartVoting' votingid='"+id+"'>Start this Voting</button>";
                 if(!App.isAdmin){
                     owneroptions = "";
                 }
                 var elementExists = document.getElementById("myvoting   "+id);
                 if(elementExists){
                     $(document).find("#myvoting"+id).html(" Voting Number:"+id+"<br>"
                              +"start:"+App.timestamptodate(data.start)+"<input type='date' value='"+App.timestamptodate(data.start)+"' id='startdateofvoting"+id+"'><button class='changestartdate' votingid='"+id+"'>change start date</button><br>"  
                              +"end:"+App.timestamptodate(data.end)+"<input type='date' value='"+App.timestamptodate(data.end)+"' id='enddateofvoting"+id+"'><button class='changeenddate' votingid='"+id+"'>change end date</button><br>"
                              +"ended:"+data.ended+"<br>"
                              +"active:"+data.activated+"<br>"
                              +"Title:"+data.title+"<input type='text' value='"+data.title+"' id='titleofvoting"+id+"'><button class='changetitle' votingid='"+id+"'>change title</button><br>"
                              +"Desc:"+data.descriptions+"<input type='text' value='"+data.descriptions+"' id='descriptionsofvoting"+id+"'><button class='changedescription' votingid='"+id+"'>change descriptions</button><br>"
                              +"<button class='StopVoting' votingid='"+id+"'>StopVoting</button><a href='/voting.html?id="+id+"'>manage Full data</a>"+owneroptions);
                 }else{
                     $(document).find("#myvotings .holder").append(
                         "<div style='border:1px solid red ;margin:5px;padding:5px' id='myvoting"+id+"'>"
                             +"Voting Number:"+id+"<br>"
                             +"start:"+App.timestamptodate(data.start)+"<input type='date' value='"+App.timestamptodate(data.start)+"' id='startdateofvoting"+id+"'><button class='changestartdate' votingid='"+id+"'>change start date</button><br>"  
                              +"end:"+App.timestamptodate(data.end)+"<input type='date' value='"+App.timestamptodate(data.end)+"' id='enddateofvoting"+id+"'><button class='changeenddate' votingid='"+id+"'>change end date</button><br>"
                              +"ended:"+data.ended+"<br>"
                              +"active:"+data.activated+"<br>"
                              +"Title:"+data.title+"<input type='text' value='"+data.title+"' id='titleofvoting"+id+"'><button class='changetitle' votingid='"+id+"'>change title</button><br>"
                              +"Desc:"+data.descriptions+"<input type='text' value='"+data.descriptions+"' id='descriptionsofvoting"+id+"'><button class='changedescription' votingid='"+id+"'>change descriptions</button><br>"
                              +"<button class='StopVoting' votingid='"+id+"'>StopVoting</button><a href='/voting.html?id="+id+"'>manage Full data</a>"+owneroptions
                        +
                         "</div>"
                     );
                 }
                 
             });
         },
         getMyVotings:async function(){

             await App.contract.methods.getMyVotings().call({from:App.account}).then(async function(result){
                 result.forEach(async function(voting){
                     await App.getMyVotingData(voting);
                 });
             });
         },
         getAllVotings:async function(){
             await App.contract.methods.lastVotingId().call().then(async function(result){
                 for(i=1;i<=result;i++){
                     await App.getMyVotingData(i);
                 }
             });
         },
         timestamptodate: function(UNIX_timestamp){
             // return UNIX_timestamp;
             var sum=UNIX_timestamp;
             var a = new Date(Number(sum));
             // return a;
             var months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
             var year = a.getFullYear();
             var month = months[a.getMonth()];
             var date = a.getDate();
             var hour = a.getHours();
             var min = a.getMinutes();
             var sec = a.getSeconds();
             var time = date + ' ' + month + ' ' + year + ' ' + hour + ':' + min + ':' + sec ;
             return time;
         },
         getVotingOptions:async function(){
            await App.contract.methods.getVotingOptions(votingId).call({from:App.account}).then(async function(result){
                $(document).find("#options .holder").html('');
                result.forEach(async function(voting){
                    await App.getOption(voting);
                });
            });
        },
        getOption: async function(id){
            await App.contract.methods.options(id).call().then(async function(data){
               
                    $(document).find("#options .holder").append(
                        "<div style='border:1px solid red ;margin:5px;padding:5px' id='myoption"+id+"'>"
                            +" Option Number:"+id+"<br>"
                             +"active:"+data.enabled+"<br>"
                             +"Title:"+data.option+"<br>"
                             +"<button class='removeoption' optionId='"+id+"'>Remove IT</button>:"+"<br>"+
                        "</div>"
                    );
                
                
            });
        },
        removeOption:async function(id){
            await App.contract.methods.removeVotingOption(votingId , id).send({from:App.account});
        },
        addOption:async function(){
            await App.contract.methods.addVotingOption(votingId ,$('#votingOptionInput').val()).send({from:App.account});
        },
        getAllVoters: async function(){
            $(document).find('#voters .holder').html('');
            await App.contract.methods.lastVoterId().call().then(async function(data){
                for(i=1;i<=data;i++){
                    await App.getVoter(i);
                }
            });
        },
        getVoter:async function(voterId ,voterAddress , searchbyaddress){
            await App.contract.methods.votersAddresses(voterId).call().then(async function(addrss){
                await App.getVoterByAddress(addrss);
            });
        },
        getVoterByAddress:async function(addrss){
            await App.contract.methods.voters(addrss).call().then(async function(data){
                    
                var elementExists =false;
                elementExists =  document.getElementById("voter   "+addrss);
             if(elementExists){
                
                $(document).find(finder).html(
                    +" Voter address:"+addrss+"<br>"
                     +"Voting Power:"+data.votingPower+"<br>"
                     +"Voting Enabled:"+data.enabled+"<br>"
                     +"<button class='enableVoter' voter='"+addrss+"'>Enable Voter</button>:"+"<br>"+
                     +"<button class='disableVoter' voter='"+addrss+"'>Disable Voter</button>:"+"<br>"+
                     +"<button class='increaseVoterPower' voter='"+addrss+"'>Increase Power of  Voter</button>:"+"<br>"+
                     +"<button class='decreaseVoterPower' voter='"+addrss+"'>decrease Power of  Voter</button>:"+"<br>"
                );

             }else{
                $(document).find('#voters').append(
                    "<div style='border:1px solid red ;margin:5px;padding:5px' id='voter"+addrss+"'>"
                    +" Voter address:"+addrss+"<br>"
                     +"Voting Power:"+data.votingPower+"<br>"
                     +"Voting Enabled:"+data.enabled+"<br>"
                     +"<button class='enableVoter' voter='"+addrss+"'>Enable Voter</button>"+"<br>"
                     +"<button class='disableVoter' voter='"+addrss+"'>Disable Voter</button>"+"<br>"
                     +"<button class='increaseVoterPower' voter='"+addrss+"'>Increase Power of  Voter</button>"+"<br>"
                     +"<button class='decreaseVoterPower' voter='"+addrss+"'>decrease Power of  Voter</button>"+"<br>"+
                    "</div>"
                );
             }
            });
        },
        addNewVoter: async function(voteraddrss){
            await App.contract.methods.addVoter(voteraddrss).send({from:App.account}).then(async function(data){

            })
        },
        enableVoter:async function(addrss){
            await App.contract.methods.enableVoter(addrss).send({from:App.account});
        },
        disableVoter:async function(addrss){
            await App.contract.methods.disableVoter(addrss).send({from:App.account});
        },
        increaseVoterPower:async function(addrss){
            await App.contract.methods.increaseVoterPower(addrss).send({from:App.account});
        },
        decreaseVoterPower:async function(addrss){
            await App.contract.methods.decreaseVoterPower(addrss).send({from:App.account});
        },
        
     };

    