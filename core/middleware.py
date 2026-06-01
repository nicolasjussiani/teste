from django.contrib.auth.models import User
from django.utils.deprecation import MiddlewareMixin

class StatelessDemoMiddleware(MiddlewareMixin):
    """
    Middleware para ambiente de demonstração (Vercel com SQLite readonly).
    Injeta o usuário logado na requisição caso o cookie 'demo_logged_in' exista.
    Assim não precisamos gravar NADA no banco de dados (nem sessão, nem last_login).
    """
    def process_request(self, request):
        if request.COOKIES.get('demo_logged_in') == 'true':
            # Pega o primeiro usuário para demonstração (geralmente admin)
            user = User.objects.first()
            if user:
                request.user = user
