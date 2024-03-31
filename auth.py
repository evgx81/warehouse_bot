from google.oauth2.service_account import Credentials
import gspread

SCOPES = [
    'https://www.googleapis.com/auth/spreadsheets',
    'https://www.googleapis.com/auth/drive'
]

credentials = Credentials.from_service_account_file("credentials.json", scopes=SCOPES)
client = gspread.authorize(credentials)