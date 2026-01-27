# SCH  [![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/InovaFiscaliza/SCH)


O SCH é uma ferramenta que possibilita consulta à base de dados dos produtos para telecomunicações com homologação expedida pela Agência, sendo útil nas fiscalizações de combate à pirataria.
- O app permite a anotação de registros da base de dados, enriquecendo-os, o que viabiliza consultas futuras mais assertivas.
- O app possibilita a automação do processo de geração de relatórios e o seu *upload* ao SEI.

<img width="1920" height="1032" src="https://github.com/user-attachments/assets/8cabbcb0-f27d-4f31-b7ba-139c7ad81e05" />

#### COMPATIBILIDADE  
A ferramenta foi desenvolvida em **MATLAB** e possui uma versão *desktop*, que pode ser utilizada em ambiente *offline*, e uma versão *webapp*, acessível na intranet. O SCH é compatível com as versões mais recentes do MATLAB (ex.: *R2024a* e *R2025a*). A versão compilada — seja *desktop* ou *webapp* — é executada sobre a máquina virtual do MATLAB, o MATLAB Runtime.  

#### EXECUÇÃO NO AMBIENTE DO MATLAB  
Caso o aplicativo seja executado diretamente no MATLAB, é necessário:  
1. Clonar o presente repositório.
2. Clonar também o repositório [SupportPackages](https://github.com/InovaFiscaliza/SupportPackages), adicionando ao *path* do MATLAB as seguintes pastas deste repositório:  
```
.\src\Anatel
.\src\General
```

3. Abrir o projeto **SCH.prj**.
4. Executar **winSCH.mlapp**.  

#### OUTRAS INFORMAÇÕES
🔗 [InovaFiscaliza/SCH](https://anatel365.sharepoint.com/sites/InovaFiscaliza/SitePages/SCH.aspx)  
