# Register updates
## Backlog1. Request a register
June 2017

GDS met with Evans Bissessar, the Government Web Domain Manager, to discuss the potential of creating a register of gov.uk domains which are reserved for use by the public sector.

Domains on gov.uk have the format of “something”.gov.uk. A register of these would complement the government-organisation, which is a list of URLs of the form gov.uk/”something”.

Evans has oversight of the registration of all new domains, which are reviewed by the Naming and Approvals Committee (NAC), chaired by Evans. The NAC also continually reviews existing domains and removes those that no longer meet the required standards. Evans publishes the list of domains annually in October.

Day to day Evans works with a team of people to maintain the data list, that are part of Jisc, a not-for-profit company that also manages the .ac.uk domain for universities. GDS met the team at Jisc to discuss how they might create and maintain the register on behalf of Evans, as they do the existing lists of domains. Any changes that Jisc makes to the domains are first approved by the NAC, which Evans chairs.
Discovery5. Review how feedback is collected
Discovery6. Review how register is updated
Discovery2. Register is accepted
Discovery3. Agree a custodian
June 2017

The RDA team made an agreement with Evans that he would be the custodian. They also agreed that Jisc were very much partners to GDS (the Data Authority) in maintaining and updating the list.
Discovery4. Agree dataset
July - August 2017

We had further conversations with Jisc about the how the register will be updated. In the immediate term, Jisc will provide monthly updates to the RDA, who will manually update the register. In the longer term, Jisc will update the register directly from their systems, via the registers API. We also agreed that the register can proceed to the beta stage before automatic updates are in place.
June 2017

The RDA team created the discovery register based on a list of domains provided by Jisc. Jisc also provided information about the organisation in government that own each domain. Using this information, the RDA linked the list of domains to several existing registers of organisations in government, such as government-organisation, local-authority-eng, local-authority-sct and internal-drainage-board.

The discovery register has the fields: government-domain; organisation (links to the government-organisation, local-authority-eng and local-authority-sct registers); start-date; end-date

We agreed the date definitions that we wanted to use:

Start date = initial registration date (the date the domain was first delegated, i.e. added to the nameservers). End date = removal date (from removal ticket) (the date the domain was removed from the nameservers)

This means that the start date won’t change if the domain owner changes from one organisation to another. If the domain expires and is then re-registered, there will be two entries (one with an end date, and one without).
Alpha7. Meet operational standards
Alpha8. Meet technical standards
Alpha9. Find duplicate lists
Beta10. Review feedback from alpha
Beta11. Remove duplicate lists
Managed by
Cabinet Office
Custodian: Evans Bissessar
Register: https://government-domain.register.gov.uk
