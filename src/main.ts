import * as express from 'express';
import { RegisterRoutes } from './routes/routes';  // cet import permet l'enrôlement des routes générées par tsoa

const app = express();
const port = 3000;

// app.get('/', (req, res) => res.send('Hello World!'));
RegisterRoutes(app);  // permet l'enrôlement des routes générées par tsoa

app.listen(port, () => console.log(`Server started listening to port ${port}`));
