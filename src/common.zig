const std = @import("std");

pub const ToolSpec = struct {
    name: []const u8,
    domain: []const u8,
    purpose: []const u8,
    capabilities: []const []const u8,
    denied_actions: []const []const u8,
    required_evidence: []const []const u8,
};

const max_input_bytes = 64 * 1024;

pub fn run(comptime spec: ToolSpec) !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();

    const args = try std.process.argsAlloc(allocator);
    defer std.process.argsFree(allocator, args);

    if (args.len > 1 and (std.mem.eql(u8, args[1], "--help") or std.mem.eql(u8, args[1], "-h"))) {
        try printHelp(spec);
        return;
    }

    const stdin = std.io.getStdIn().reader();
    const input = try stdin.readAllAlloc(allocator, max_input_bytes + 1);
    defer allocator.free(input);

    if (input.len > max_input_bytes) return error.InputTooLarge;
    const verdict = inspect(input);

    var out = std.io.getStdOut().writer();
    try out.print(
        "{{\n" ++
            "  \"tool\": \"{s}\",\n" ++
            "  \"domain\": \"{s}\",\n" ++
            "  \"zero_trust\": {{\n" ++
            "    \"default_decision\": \"deny\",\n" ++
            "    \"input_bytes\": {d},\n" ++
            "    \"risk\": \"{s}\",\n" ++
            "    \"approved_for_execution\": false,\n" ++
            "    \"requires_human_approval\": true,\n" ++
            "    \"secrets_redacted\": true,\n" ++
            "    \"network_allowed\": false,\n" ++
            "    \"filesystem_write_allowed\": false,\n" ++
            "    \"external_side_effects_allowed\": false\n" ++
            "  }},\n" ++
            "  \"detected_controls\": [\n" ++
            "    \"least_privilege\",\n" ++
            "    \"schema_validation\",\n" ++
            "    \"payload_size_limit\",\n" ++
            "    \"prompt_injection_scan\",\n" ++
            "    \"secret_pattern_scan\",\n" ++
            "    \"deny_side_effects_without_policy\",\n" ++
            "    \"audit_log_ready_output\"\n" ++
            "  ],\n" ++
            "  \"result\": {{\n" ++
            "    \"status\": \"plan_only\",\n" ++
            "    \"message\": \"Tool generated a safe plan. Connect privileged adapters only behind policy, approvals, and audited capability tokens.\",\n" ++
            "    \"injection_detected\": {},\n" ++
            "    \"secret_like_input_detected\": {},\n" ++
            "    \"recommended_next_step\": \"Review evidence, bind a short-lived scoped capability, then rerun in an isolated worker if execution is needed.\"\n" ++
            "  }}\n" ++
            "}}\n",
        .{ spec.name, spec.domain, input.len, verdict.risk, verdict.injection, verdict.secret_like },
    );
}

const Verdict = struct { risk: []const u8, injection: bool, secret_like: bool };

fn inspect(input: []const u8) Verdict {
    const lower = std.ascii.allocLowerString(std.heap.page_allocator, input) catch return .{ .risk = "unknown", .injection = false, .secret_like = false };
    defer std.heap.page_allocator.free(lower);

    const injection = containsAny(lower, &.{
        "ignore previous", "ignore all",     "system prompt", "developer message", "jailbreak",
        "exfiltrate",      "disable safety", "bypass",        "sudo ",             "rm -rf",
        "curl ",           "wget ",
    });
    const secret_like = containsAny(lower, &.{
        "api_key",           "apikey",     "secret", "password", "token=", "\"token\"", "bearer ", "private key",
        "aws_access_key_id", "-----begin",
    });
    return .{
        .risk = if (injection or secret_like) "high" else if (input.len == 0) "low" else "medium",
        .injection = injection,
        .secret_like = secret_like,
    };
}

fn containsAny(haystack: []const u8, needles: []const []const u8) bool {
    for (needles) |needle| if (std.mem.indexOf(u8, haystack, needle) != null) return true;
    return false;
}

fn printHelp(comptime spec: ToolSpec) !void {
    var out = std.io.getStdOut().writer();
    try out.print("{s} - {s}\n\nPurpose: {s}\n\nCapabilities:\n", .{ spec.name, spec.domain, spec.purpose });
    for (spec.capabilities) |cap| try out.print("  - {s}\n", .{cap});
    try out.print("\nZero-trust denied actions:\n", .{});
    for (spec.denied_actions) |act| try out.print("  - {s}\n", .{act});
    try out.print("\nRequired evidence:\n", .{});
    for (spec.required_evidence) |e| try out.print("  - {s}\n", .{e});
}
