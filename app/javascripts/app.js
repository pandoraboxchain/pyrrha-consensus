// Import the page's CSS. Webpack will know what to do with it.
import '../stylesheets/app.css'

// Import libraries we need.
import { default as Web3 } from 'web3'
import { default as contract } from 'truffle-contract'

// Import our contract artifacts and turn them into usable abstractions.
import pandoraArtifacts from '../../build/contracts/Pandora.json'
import kernelArtifacts from '../../build/contracts/Kernel.json'
import datasetArtifacts from '../../build/contracts/Dataset.json'

// Neurochain is our usable abstraction, which we'll use through the code below.
let Pandora = contract(pandoraArtifacts)
let Kernel = contract(kernelArtifacts)
let Dataset = contract(datasetArtifacts)

let accounts
let account

window.App = {
  start: function () {
    Pandora.setProvider(web3.currentProvider)
    Kernel.setProvider(web3.currentProvider)
    Dataset.setProvider(web3.currentProvider)

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

    Pandora.deployed().then(function (pandora) {
      console.log('Deployed Pandora ' + pandora.address)
      console.log('Waiting for events')
      pandora.allEvents().watch(function (error, result) {
        if (!error) {
          console.log('Event happened')
          console.log(result)
        } else {
          console.error(error)
        }
      })
    })

    Kernel.deployed().then(function (kernel) {
      window.App.kernelContract = kernel
      console.log('Deployed kernel ' + kernel.address)
    })

    Dataset.deployed().then(function (dataset) {
      window.App.datasetContract = dataset
      console.log('Deployed dataset ' + dataset.address)
    })
  },

  setStatus: function (message) {
    let status = document.getElementById('status')
    status.innerHTML = message
  },

  createKernel: function () {
    this.setStatus('Creating kernel... (please wait)')

  },

  createDataset: function () {
    this.setStatus('Creating dataset... (please wait)')
  },

  deployCognitiveJob: function () {
    let self = this

    this.setStatus('Initiating transaction... (please wait)')

    Pandora.deployed().then(function (pandora) {
      return pandora.createCognitiveJob(
        window.App.kernelContract.address,
        window.App.datasetContract.address,
        { from: account, gas: 2000000 }
      )
    }).then(function (cognitiveJob) {
      self.setStatus('Cognitive job created with address ' + cognitiveJob)
      console.log('Cognitive job deployed')
      console.log(cognitiveJob)
    }).catch(function (e) {
      console.log(e)
      self.setStatus('Error deploying cognitive job; see log.')
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
