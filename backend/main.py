import os
import random
import string
import shutil
import zipfile
from typing import List
from fastapi import FastAPI, UploadFile, File, Request, HTTPException
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from fastapi.responses import FileResponse, JSONResponse
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="NextHouse Instant Share Backend")

# Consenti CORS per sviluppo e test
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Assicura l'esistenza delle cartelle per l'archiviazione
UPLOAD_DIR = "static/sessions"
os.makedirs(UPLOAD_DIR, exist_ok=True)
os.makedirs("templates", exist_ok=True)

# Monta la cartella statica per accedere alle immagini
app.mount("/static", StaticFiles(directory="static"), name="static")

# Configura i template HTML
templates = Jinja2Templates(directory="templates")


def generate_session_code(length: int = 6) -> str:
    """Genera un codice alfanumerico univoco e leggibile per la sessione."""
    characters = string.ascii_uppercase + string.digits
    # Escludi caratteri ambigui come O, 0, I, 1 per facilitare la lettura
    ambiguous = ['O', '0', 'I', '1']
    clean_chars = [c for c in characters if c not in ambiguous]
    
    while True:
        code = "".join(random.choices(clean_chars, k=length))
        # Verifica che la cartella per questa sessione non esista già
        if not os.path.exists(os.path.join(UPLOAD_DIR, code)):
            return code


@app.post("/api/sessions/upload")
async def upload_photos(request: Request, files: List[UploadFile] = File(...)):
    """
    Riceve le foto della sessione corrente in formato multipart/form-data.
    Crea una cartella di sessione univoca e vi salva i file.
    Restituisce il link per la condivisione e il codice breve.
    """
    if not files:
        raise HTTPException(status_code=400, detail="Nessun file inviato.")
        
    session_id = generate_session_code()
    session_path = os.path.join(UPLOAD_DIR, session_id)
    os.makedirs(session_path, exist_ok=True)
    
    saved_files = []
    try:
        for index, file in enumerate(files):
            # Normalizza il nome del file mantenendo l'estensione originale
            ext = os.path.splitext(file.filename)[1] if file.filename else ".jpg"
            if not ext:
                ext = ".jpg"
            filename = f"photo_{index + 1}{ext}"
            file_path = os.path.join(session_path, filename)
            
            with open(file_path, "wb") as buffer:
                shutil.copyfileobj(file.file, buffer)
            saved_files.append(filename)
    except Exception as e:
        # Pulisci in caso di errore
        if os.path.exists(session_path):
            shutil.rmtree(session_path)
        raise HTTPException(status_code=500, detail=f"Errore durante il salvataggio dei file: {str(e)}")

    # Determina l'URL di base (configurabile tramite variabile d'ambiente BASE_URL o ricavato dalla richiesta)
    base_url = os.getenv("BASE_URL")
    if not base_url:
        base_url = str(request.base_url).rstrip("/")
        
    share_url = f"{base_url}/share/{session_id}"
    
    return {
        "session_id": session_id,
        "share_url": share_url,
        "code": session_id,
        "files": saved_files
    }


@app.get("/share/{session_id}")
async def get_share_gallery(request: Request, session_id: str):
    """
    Mostra la pagina web della galleria con le foto caricate.
    """
    session_path = os.path.join(UPLOAD_DIR, session_id)
    if not os.path.exists(session_path) or not os.path.isdir(session_path):
        raise HTTPException(status_code=404, detail="Sessione di condivisione non trovata.")
        
    # Elenca solo i file immagine (esclude eventuali zip o cartelle nascoste)
    files = [
        f for f in os.listdir(session_path) 
        if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp'))
    ]
    files.sort()
    
    # URL di base per caricare le immagini
    base_url = os.getenv("BASE_URL")
    if not base_url:
        base_url = str(request.base_url).rstrip("/")
        
    image_urls = [f"{base_url}/static/sessions/{session_id}/{f}" for f in files]
    
    return templates.TemplateResponse(
        "share.html",
        {
            "request": request,
            "session_id": session_id,
            "images": image_urls,
            "download_zip_url": f"{base_url}/share/{session_id}/download"
        }
    )


@app.get("/share/{session_id}/download")
async def download_all_zip(session_id: str):
    """
    Crea un archivio ZIP contenente tutte le foto della sessione e lo restituisce.
    L'archivio viene memorizzato temporaneamente sul disco della sessione per evitare ricreazioni continue.
    """
    session_path = os.path.join(UPLOAD_DIR, session_id)
    if not os.path.exists(session_path) or not os.path.isdir(session_path):
        raise HTTPException(status_code=404, detail="Sessione non trovata.")
        
    zip_filename = f"nexthouse_{session_id}.zip"
    zip_path = os.path.join(session_path, zip_filename)
    
    # Se il file ZIP non esiste ancora, crealo
    if not os.path.exists(zip_path):
        files = [
            f for f in os.listdir(session_path)
            if f.lower().endswith(('.png', '.jpg', '.jpeg', '.gif', '.webp')) and f != zip_filename
        ]
        
        if not files:
            raise HTTPException(status_code=400, detail="Nessuna foto disponibile per il download.")
            
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for f in files:
                file_full_path = os.path.join(session_path, f)
                zipf.write(file_full_path, f)
                
    return FileResponse(
        zip_path,
        media_type="application/x-zip-compressed",
        filename=zip_filename
    )
