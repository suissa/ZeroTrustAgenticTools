#!/usr/bin/env node
import { run } from "../common.js";
import {
  makeToolName,
  makeDomain,
  makePurpose,
  makeCapability,
  makeDeniedAction,
  makeRequiredEvidence
} from "./interface.js";

const spec = {
  name: makeToolName("ztat-ts-wa-user-privacy"),
  domain: makeDomain("whatsapp user operations"),
  purpose: makePurpose("Get a user's privacy settings"),
  capabilities: [
    makeCapability("Get a user's privacy settings"),
    makeCapability("validates all input as untrusted"),
    makeCapability("returns plan-only JSON by default"),
    makeCapability("requires scoped capability tokens for side effects")
  ],
  denied_actions: [
    makeDeniedAction("no autonomous money movement, purchasing, deletion, messaging, or network access"),
    makeDeniedAction("no secret echoing or credential persistence"),
    makeDeniedAction("no execution of user-provided commands")
  ],
  required_evidence: [
    makeRequiredEvidence("authenticated actor and tenant"),
    makeRequiredEvidence("explicit task policy"),
    makeRequiredEvidence("source provenance"),
    makeRequiredEvidence("approval for regulated or irreversible actions"),
    makeRequiredEvidence("audit correlation id")
  ]
};

run(spec);
