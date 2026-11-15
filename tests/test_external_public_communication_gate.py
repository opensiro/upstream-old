"""Regression: an agent cannot infer outbound consent from Upstream's standing PR mandate."""
from pathlib import Path
import json
import unittest

ROOT=Path(__file__).resolve().parents[1]
POLICY=json.loads((ROOT/'policies/standing-external-publication-p1.json').read_text())
GATE=(ROOT/'docs/EXTERNAL_PUBLIC_COMMUNICATION_GATE.md').read_text()

class ExternalPublicCommunicationGateTests(unittest.TestCase):
    def test_default_block_even_with_standing_pr_grant(self):
        self.assertEqual(POLICY['status'],'ACTIVE')
        self.assertEqual(POLICY['approval_mode'],'EXPLICIT_OWNER_CONFIRMATION_PER_PUBLIC_ACTION')
        g=POLICY['external_public_write_gate']
        self.assertEqual(g['default_decision'],'BLOCK_UNTIL_EXPLICIT_OWNER_APPROVAL')
        self.assertFalse(g['inferred_approval_is_valid'])
        self.assertTrue(g['no_unattended_external_communication'])
        self.assertTrue(g['preparation_only_without_new_approval'])
        self.assertIn('exact_current_owner_approval_before_any_external_public_write',POLICY['required_checks'])
        self.assertIn('third_party_public_communication_without_exact_current_owner_approval',POLICY['reserved_actions'])

    def test_comments_issues_prs_reviews_and_public_fork_prs_in_scope(self):
        actions=set(POLICY['external_public_write_gate']['scope'])
        for act in ('external_issue_comment','external_pr_comment','external_pr_review',
                    'create_external_issue','submit_external_pr','edit_external_pr',
                    'fork_local_public_pr','external_discussion_or_reply'):
            with self.subTest(action=act):
                self.assertIn(act,actions)
        for bind in ('exact_action','exact_third_party_destination',
                     'exact_public_text_or_pr_diff','current_conversation_owner_instruction','single_use'):
            self.assertIn(bind,POLICY['external_public_write_gate']['approval_binding'])

    def test_no_stale_or_generic_approval(self):
        deny=set(POLICY['external_public_write_gate']['inferred_approval_from'])
        for value in ('continue','upstream_auto','batch_or_wave','standing_p1',
                      'passing_tests','source_issue_request','prior_chat_approval'):
            self.assertIn(value,deny)
        for scenario in ('Akmatori #48','current conversation','BLOCK',
                         'comment or reply','public fork-local PR'):
            self.assertIn(scenario.lower(),GATE.lower())
        self.assertIn('cannot technically intercept',GATE)

    def test_active_routes_link_gate_not_old_no_prompt_instruction(self):
        docs=('AGENTS.md','README.md','UPSTREAMING.md','docs/EXTERNAL_PUBLICATION_WAVES.md',
              'docs/CONTINUOUS_WORKING_FORK_PIPELINE.md','docs/OPERATIONS.md',
              'docs/STANDING_EXTERNAL_PR_PUBLICATION.md')
        for path in docs:
            with self.subTest(path=path):
                s=(ROOT/path).read_text()
                self.assertIn('EXTERNAL_PUBLIC_COMMUNICATION_GATE.md',s)
        self.assertEqual((ROOT/'VERSION').read_text().strip(),'0.10.0')
        self.assertIn('v0.10.0', (ROOT/'CHANGELOG.md').read_text())
        self.assertTrue((ROOT/'changes/v0.10.0.md').is_file())

if __name__=='__main__':
    unittest.main()
