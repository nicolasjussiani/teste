import fitz
import pytesseract
from PIL import Image
import io

pytesseract.pytesseract.tesseract_cmd = r'C:\Program Files\Tesseract-OCR\tesseract.exe'

try:
    doc = fitz.open('Teste_OCR/curriculo.pdf')
    texto = ""
    for page in doc:
        # Tenta texto normal primeiro
        page_text = page.get_text()
        if len(page_text.strip()) > 5:
            texto += page_text + "\n"
        else:
            print(f"Página {page.number} vazia, aplicando OCR...")
            pix = page.get_pixmap(dpi=150)
            img = Image.open(io.BytesIO(pix.tobytes()))
            ocr_text = pytesseract.image_to_string(img, lang='por')
            texto += ocr_text + "\n"
    
    print("--- TEXTO FINAL ---")
    print(texto[:500])
except Exception as e:
    print("Erro:", e)
