type ChatRole = 'user' | 'assistant';

type ProxyMessage = {
  role: ChatRole;
  content: string;
};

type ProxyRequest = {
  messages?: ProxyMessage[];
};

type AnthropicResponse = {
  content?: Array<{ type: string; text?: string }>;
};

type AnthropicErrorResponse = {
  error?: {
    message?: string;
  };
};

const ANTHROPIC_URL = 'https://api.anthropic.com/v1/messages';
const ANTHROPIC_API_KEY = Deno.env.get('ANTHROPIC_API_KEY');
const ANTHROPIC_MODEL = Deno.env.get('ANTHROPIC_MODEL') ?? 'claude-sonnet-4-20250514';
const MAX_MESSAGES = 16;
const MAX_MESSAGE_CHARS = 4000;

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

const systemPrompt = `
Você é NathIA, uma companheira de maternidade para gestantes e mães brasileiras no app Nossa Maternidade,
frontado por Nathália Valente.

Responda sempre em português do Brasil. Seja uma amiga brasileira calorosa, aterrada, feminina e confiante,
sem exageros. Acolha primeiro, depois oriente com simplicidade. Não substitua profissionais de saúde.

Regras de segurança:
- Nunca diagnostique.
- Nunca prescreva medicação.
- Nunca use "isso é normal" de forma dismissiva.
- Se houver incerteza médica, diga: "Fala com tua obstetra, tá?"
- Para sinais de alerta, oriente contato com obstetra ou pronto atendimento.
- Não use linguagem de medo.
- Não soe como chatbot de hospital.
- Mantenha respostas curtas, humanas e calmantes.

Estilo de resposta:
"Respira. Uma coisa de cada vez. Me conta o que você está sentindo agora - no corpo e no coração."
`.trim();

Deno.serve(async (request) => {
  if (request.method === 'OPTIONS') {
    return json({ ok: true });
  }

  if (request.method !== 'POST') {
    return json({ message: 'Método não permitido.' }, 405);
  }

  if (!ANTHROPIC_API_KEY) {
    return json({ message: 'NathIA indisponível: chave Anthropic ausente no backend.' }, 500);
  }

  const body = await parseBody(request);
  if (!body.ok) {
    return json({ message: body.message }, 400);
  }

  const anthropicResponse = await fetch(ANTHROPIC_URL, {
    method: 'POST',
    headers: {
      'content-type': 'application/json',
      'x-api-key': ANTHROPIC_API_KEY,
      'anthropic-version': '2023-06-01',
    },
    body: JSON.stringify({
      model: ANTHROPIC_MODEL,
      system: systemPrompt,
      max_tokens: 520,
      messages: body.messages,
    }),
  });

  const responseText = await anthropicResponse.text();
  if (!anthropicResponse.ok) {
    return json({ message: anthropicErrorMessage(responseText) }, anthropicResponse.status);
  }

  const decoded = safeParse<AnthropicResponse>(responseText);
  const message = decoded?.content?.map((item) => item.text ?? '').join('\n').trim() ?? '';

  if (!message) {
    return json({ message: 'A NathIA não conseguiu responder agora.' }, 502);
  }

  return json({ message });
});

async function parseBody(request: Request): Promise<
  | { ok: true; messages: ProxyMessage[] }
  | { ok: false; message: string }
> {
  const decoded = safeParse<ProxyRequest>(await request.text());
  const messages = decoded?.messages;

  if (!Array.isArray(messages) || messages.length === 0) {
    return { ok: false, message: 'Envie ao menos uma mensagem para a NathIA.' };
  }

  const normalized = messages
    .slice(-MAX_MESSAGES)
    .map(normalizeMessage)
    .filter((message): message is ProxyMessage => message !== null);

  if (normalized.length === 0) {
    return { ok: false, message: 'Mensagem vazia para a NathIA.' };
  }

  return { ok: true, messages: normalized };
}

function normalizeMessage(message: ProxyMessage): ProxyMessage | null {
  if (message.role !== 'user' && message.role !== 'assistant') {
    return null;
  }

  const content = String(message.content ?? '')
    .replace(/<\/?user_message>/gi, '')
    .slice(0, MAX_MESSAGE_CHARS)
    .trim();

  return content ? { role: message.role, content } : null;
}

function anthropicErrorMessage(body: string): string {
  const decoded = safeParse<AnthropicErrorResponse>(body);
  return decoded?.error?.message ?? 'A NathIA oscilou um pouquinho. Tenta de novo daqui a pouco.';
}

function safeParse<T>(body: string): T | null {
  try {
    return JSON.parse(body) as T;
  } catch {
    return null;
  }
}

function json(body: Record<string, unknown>, status = 200): Response {
  return new Response(JSON.stringify(body), {
    status,
    headers: {
      ...corsHeaders,
      'Content-Type': 'application/json',
    },
  });
}
