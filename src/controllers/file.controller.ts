import { Post, Get, Route, Security, Response, Request } from 'tsoa';
import * as express from 'express';
import * as multer from 'multer';
import * as path from 'path';
import * as fs from 'fs';


@Route('files')
export class FilesController {
  wSubfolder: string;
  static wSubfolderStatic: string;
  constructor() {
    this.wSubfolder = "defaultSubfolderOne";
    this.handleFile = this.handleFile.bind(this);
  }
  // https://scotch.io/tutorials/express-file-uploads-with-multer
  // https://stackabuse.com/handling-file-uploads-in-node-js-with-expres-and-multer/
  // https://symmetrycode.com/super-easy-image-uploads-with-multer-and-express/
  @Post('uploadFile')
  public async uploadFile(@Request() request: express.Request): Promise<any> {
    this.wSubfolder = request.body.cheminFichierSousEdition;
    let pokusStorageOnDisk = await this.handleFile(request, request.body.cheminFichierSousEdition);
    // file will be in request.fichierSousEdition, it is a buffer
    console.log ('J ai invoque le endpoint upload file');
    let cheminFichierDansGitRepoPre = request.body.cheminFichierSousEdition;
    let cheminFichierDansGitRepo = cheminFichierDansGitRepoPre.replace(/"/g,'');
    let cheminCOMPLETFichierDansGitRepo = process.env.POKUS_GITOPS + '/' + cheminFichierDansGitRepo;
    let cheminCOMPLETFichierUpload = process.env.POKUS_UPLOADS + '/' + cheminFichierDansGitRepo.split('/').pop();

    let repertoireSplits = str.split('/');
    let repertoire = repertoireSplits.splice(-1, (splits.length - 1));

    let cheminCOMPLETRepertoireDansGitRepo = process.env.POKUS_GITOPS + '/' + repertoire;

    console.log(" Valeur [request.body.cheminFichierSousEdition] = [" + request.body.cheminFichierSousEdition + "]");
    console.log(" Valeur [cheminFichierDansGitRepo] = [" + cheminFichierDansGitRepo + "]");
    console.log(" Valeur [cheminCOMPLETFichierDansGitRepo] = [" + cheminCOMPLETFichierDansGitRepo + "]");
    console.log(" Valeur [cheminCOMPLETFichierUpload] = [" + cheminCOMPLETFichierUpload + "]");
    console.log(" Valeur [cheminCOMPLETRepertoireDansGitRepo] = [" + cheminCOMPLETRepertoireDansGitRepo + "]");

    // destination.txt will be created or overwritten by default.
    fs.copyFile(cheminCOMPLETFichierUpload, 'destination.txt', (err) => {
      if (err) throw err;
      console.log('source.txt was copied to destination.txt');
    });
    console.log( "  Valeur de [process.env.POKUS_WKSP] = [" + process.env.POKUS_WKSP + "]");
    console.log( "  Valeur de [process.env.POKUS_UPLOADS] = [" + process.env.POKUS_UPLOADS + "]");
    console.log( "  Valeur de [process.env.POKUS_GITOPS] = [" + process.env.POKUS_GITOPS + "]");
    return { msg: 'J ai invoque le endpoint upload file', cheminFichierDansGitRepo: cheminFichierDansGitRepo };
  }

  private handleFile(request: express.Request, subfolder: string): Promise<any> {

    const pokusStorageOnDisk = multer.diskStorage({
      destination: function(req, file, cb) {
        //console.log(" [multer.diskStorage#destination] Valeur req.body : [" + req.body + "]");
        // console.log(" [multer.diskStorage#destination] Valeur req.session : [" + req.session + "]");
          // le repertoire [process.Env.POKUS_UPLOADS] doit exister
          console.log(" ++ [" + process.env.POKUS_UPLOADS + "] decide du chemin du workspace par config : ");
          cb(null, process.env.POKUS_UPLOADS);
      },

      // By default, multer removes file extensions so let's add them back
      filename: function(req, file, cb) {
        // console.log(" [multer.diskStorage#filename] Valeur generee : [" + file.fieldname + '-' + Date.now() + path.extname(file.originalname) + "]");
        // console.log(" [multer.diskStorage#filename] Valeur file.originalname : [" + file.originalname + "]");
        // console.log(" [multer.diskStorage#filename] Valeur path.extname(file.originalname) : [" + path.extname(file.originalname) + "]");
        cb(null, file.originalname);
      }
    });
    // The main multer object
    const pokusSingleMulter = multer({
      storage: pokusStorageOnDisk
    }).single('fichierSousEdition');
    //console.log(" TEST DU MULTER SINGLE TRAITE : [" + multerSingle + "]")
    return new Promise((resolve, reject) => {
      pokusSingleMulter(request, undefined, async (error) => {
        if (error) {
          reject(error);
        }
        resolve();
      });
    });
  }
}
