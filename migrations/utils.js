'use strict';

const fs = require('fs');
const path = require('path');

/**
 * Save contract address to file
 * 
 * @param {String} basePath Path where file should be saved
 * @param {String} fileName 
 * @param {String} address File data
 */
module.exports.saveAddressToFile = (basePath, fileName, address) => new Promise((resolve, reject) => {
    const savePath = path.join(basePath, '../build/addresses');
    const filePath = path.join(savePath, fileName);
    const callback = err => {
        
        if (err) {

            return reject(err);
        }

        resolve();
    }

    fs.stat(savePath, (err) => {

        if (err) {

            return fs.mkdir(savePath, err => {

                if (err) {

                    return reject(err);
                }

                fs.writeFile(filePath, address, 'utf8', callback);
            });
        }

        fs.writeFile(filePath, address, 'utf8', callback);
    });
});