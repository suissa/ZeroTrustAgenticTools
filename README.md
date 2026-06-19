# ZeroTrustAgenticTools

Coleção de ferramentas para agentes, escritas em Zig, com postura **zero trust por padrão**.
Cada binário recebe uma solicitação via `stdin`, trata todo conteúdo como não confiável e retorna um JSON auditável em modo `plan_only`. Nenhuma ferramenta executa ações externas diretamente: dinheiro, compras, mensagens, gravação em disco, rede, comandos e integrações privilegiadas exigem políticas explícitas, aprovação humana e tokens de capacidade de curta duração.

## Ferramentas

O `build.zig` gera estes binários:

| Binário | Domínio |
| --- | --- |
| `ztat-finance` | tarefas financeiras |
| `ztat-accounting` | tarefas contábeis |
| `ztat-support` | atendimento ao cliente |
| `ztat-sales` | vendas |
| `ztat-security` | segurança |
| `ztat-infra` | infraestrutura |
| `ztat-data-analysis` | análise de dados |
| `ztat-personal-assistant` | assistente pessoal |
| `ztat-digital-twin` | gêmeo digital |
| `ztat-personal-shopper` | personal shopper |
| `ztat-scraper` | scrapper/coleta web |
| `ztat-premium-layout` | criador de layouts premium |

## Modelo zero trust

Todas as tools compartilham os mesmos controles centrais em `src/common.zig`:

- **negação por padrão**: a saída informa `approved_for_execution: false`;
- **menor privilégio**: side effects precisam ser conectados por adaptadores externos com escopo mínimo;
- **limite de payload**: entradas acima de 64 KiB são recusadas;
- **varredura de prompt injection**: padrões como jailbreak, bypass e comandos perigosos elevam risco;
- **varredura de segredos**: tokens, senhas, chaves e private keys são marcados como sensíveis;
- **sem rede e sem escrita** por padrão;
- **auditoria**: o resultado é JSON determinístico e pronto para logs.

> Observação: nenhuma implementação consegue “mitigar todas as brechas existentes atualmente” de forma absoluta. Este projeto implementa uma base defensiva forte e extensível; integrações reais devem adicionar sandboxing de SO, allowlists de destino, OPA/Rego ou equivalente, autenticação forte, segregação por tenant, rate limits, SAST/DAST, SBOM e revisão contínua.

## Build

Instale Zig e execute:

```sh
zig build
```

Os executáveis serão instalados em `zig-out/bin`.

## Uso

```sh
printf '{"task":"analisar fluxo de caixa"}' | zig-out/bin/ztat-finance
zig-out/bin/ztat-security --help
```

## Desenvolvimento

- Adicione novas tools criando `src/<nome>.zig` com uma `ToolSpec` e registrando o nome em `build.zig`.
- Mantenha ações privilegiadas fora do binário de domínio; use adaptadores isolados e autorizados.
- Nunca persista ou ecoe segredos recebidos como entrada.

## Implementações adicionais

Além dos binários Zig `ztat-*`, o repositório inclui as mesmas tools em outras linguagens para facilitar adoção por runtimes diferentes:

| Linguagem | Diretório | Prefixo de binário | Build/check |
| --- | --- | --- | --- |
| TypeScript | `ts/` | `ztat-ts-*` | `npm run build` dentro de `ts/` |
| Python | `py/` | `ztat-py-*` | `python -m compileall py/ztat_tools` |
| Go | `go/` | `ztat-go-*` | `go build ./...` dentro de `go/` |
| Rust | `rs/` | `ztat-rs-*` | `cargo build` dentro de `rs/` |

Todas as implementações preservam o mesmo contrato zero-trust: entrada por `stdin`, limite de 64 KiB, modo `plan_only`, varredura de prompt injection, varredura de segredos, negação de rede/escrita/side effects e formato JSON auditável.
