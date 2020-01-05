import { Post, Request, Response, Route, SuccessResponse, Tags } from 'tsoa'

import * as express from 'express'
import * as multer from 'multer'
import { StatusError } from '../models/StatusError'

@Route('files')
export class FilesController {

  @Tags('File')
  @SuccessResponse('204', 'successful')
  @Response('400', 'invalid file supplied')
  @Post('uploadFile')
  public async uploadImageFile (@Request() request: express.Request): Promise {
    await this.handleFile(request, 'imageFile', 'zip', 'tmp', 'img.zip')
    // file will be in request.imageFile, it is a buffer
  }

  private async handleFile (request: express.Request,
                            requestField: string,
                            filterExt: string,
                            storePath: string,
                            fileName?: string): Promise {
    const fileFilter = (req: Express.Request, file: Express.Multer.File,
                        callback: (error: Error | null, acceptFile: boolean) => void) => {
      // accept image only
      if (!file.originalname.match(`^(.*\\.((${filterExt})$))
      console.log("Nom fichier : [" + file.originalname + "]" )
    }
  }

  @Tags('File')
  @SuccessResponse('200', 'successful')
  // @Produces('application/zip, application/octet-stream') // hopefully this will work in the near future
  @Get('download/image')
  public async downloadImageFile (): Promise {
    const absPath = await service.generateImageFile()
    return FileResult.newInstance({ path: absPath })
  }
}
