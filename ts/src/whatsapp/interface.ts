declare const brand: unique symbol;
export type Nominal<T, B> = T & { readonly [brand]: B };

export type ToolName = Nominal<string, "ToolName">;
export type Domain = Nominal<string, "Domain">;
export type Purpose = Nominal<string, "Purpose">;
export type Capability = Nominal<string, "Capability">;
export type DeniedAction = Nominal<string, "DeniedAction">;
export type RequiredEvidence = Nominal<string, "RequiredEvidence">;

export type CapabilitiesList = Capability[];
export type DeniedActionsList = DeniedAction[];
export type RequiredEvidenceList = RequiredEvidence[];

export type WhatsAppToolSpec = {
  readonly name: ToolName;
  readonly domain: Domain;
  readonly purpose: Purpose;
  readonly capabilities: CapabilitiesList;
  readonly denied_actions: DeniedActionsList;
  readonly required_evidence: RequiredEvidenceList;
};

export function makeToolName(val: string): ToolName {
  return val as ToolName;
}

export function makeDomain(val: string): Domain {
  return val as Domain;
}

export function makePurpose(val: string): Purpose {
  return val as Purpose;
}

export function makeCapability(val: string): Capability {
  return val as Capability;
}

export function makeDeniedAction(val: string): DeniedAction {
  return val as DeniedAction;
}

export function makeRequiredEvidence(val: string): RequiredEvidence {
  return val as RequiredEvidence;
}
