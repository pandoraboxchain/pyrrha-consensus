// Import the page's CSS. Webpack will know what to do with it.
import '../stylesheets/app.css'

// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import neurochainArtifacts from '../../build/contracts/Neurochain.json'

// Neurochain is our usable abstraction, which we'll use through the code below.
let Neurochain = contract(neurochainArtifacts)

let accounts
let account

window.App = {
  start: function () {
    // Bootstrap the Neurochain abstraction for Use.
    Neurochain.setProvider(web3.currentProvider)

    web3.eth.getAccounts(function (err, accs) {
      if (err !== null) {
        window.alert('There was an error fetching your accounts.')
        return
      }

      if (accs.length === 0) {
        window.alert("Couldn't get any accounts! Make sure your Ethereum client is configured correctly.")
        return
      }

      accounts = accs
      account = accounts[0]
      console.log('Listening available accounts')
      console.log(accounts)
    })

    Neurochain.deployed().then(function (neurochain) {
      console.log(neurochain)
      console.log('Waiting for events')
      neurochain.allEvents().watch(function (error, result) {
        if (!error) {
          console.log('Event happened')
          console.log(result)
        } else {
          console.error(error)
        }
      })
            /*
             var NeurochainContract = web3.eth.contract(Neurochain.abi)
             var rootContract = NeurochainContract.at(neurochain.address)
             var event = rootContract.NewNeurocontract()
             console.log('Waiting for new neurocontracts')
             event.watch(function (error, result) {
             if (!error) {
             console.log(result)
             alert(result)
             } else {
             console.error(error)
             }
             })
             */
    })
  },

  setStatus: function (message) {
    let status = document.getElementById('status')
    status.innerHTML = message
  },

  deployNeurocontract: function () {
    let self = this

    this.setStatus('Initiating transaction... (please wait)')

    Neurochain.deployed().then(function (neurochain) {
      return neurochain.deployNeurocontract(
        '0x5294f483825c4e2502722ae0b00f3d00597347f6',
        '0xb20fddd30b0153d322db3b0d84649bb646553532',
        1,
        { from: account, gas: 2000000 }
      )
    }).then(function (neurocontract) {
      self.setStatus('Neurocontract created with address ' + neurocontract)
      console.log('Neurocontract deployed')
      // console.log(neurocontract)
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error deploying neurocontract; see log.')
    })
  }
}

window.addEventListener('load', function () {
    // Checking if Web3 has been injected by the browser (Mist/MetaMask)
  if (typeof web3 !== 'undefined') {
    console.warn(
        'Using web3 detected from external source. ' +
        "If you find that your accounts don't appear or you have 0 MetaCoin, " +
        "ensure you've configured that source properly. If using MetaMask, see the following link. " +
        'Feel free to delete this warning. :) http://truffleframework.com/tutorials/truffle-and-metamask'
  )
        // Use Mist/MetaMask's provider
    window.web3 = new Web3(web3.currentProvider)
  } else {
    console.warn(
        'No web3 detected. Falling back to http://localhost:8545. ' +
        "You should remove this fallback when you deploy live, as it's inherently insecure. " +
        'Consider switching to Metamask for development. More info here: ' +
        'http://truffleframework.com/tutorials/truffle-and-metamask')
        // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    window.web3 = new Web3(new Web3.providers.HttpProvider('http://localhost:8545'))
  }

  App.start()
})
