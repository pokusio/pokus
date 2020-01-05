import * as express from 'express';
import { RegisterRoutes } from './routes/routes';  // cet import permet l'enrÃ´lement des routes gÃ©nÃ©rÃ©es par tsoa
// const path = require('path');
import * as path from 'path';
import * as multer from 'multer';

const app = express();
const port = 3000;




const pokusStorageOnDisk = multer.diskStorage({
    destination: function(req, file, cb) {
        cb(null, 'worspace/pokus');
    },

    // By default, multer removes file extensions so let's add them back
    filename: function(req, file, cb) {
        cb(null, file.fieldname + '-' + Date.now() + path.extname(file.originalname));
    }
});


// app.get('/', (req, res) => res.send('Hello World!'));
RegisterRoutes(app);  // permet l'enrÃ´lement des routes gÃ©nÃ©rÃ©es par tsoa





app.listen(port, () => console.log(`Server started listening to port ${port}`));
